// LWNetworkReachabilityManager.swift
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SystemConfiguration

#if !os(watchOS)

/// Network reachability status
public enum NetworkReachabilityStatus: Int {
    case unknown = -1
    case notReachable = 0
    case reachableViaWWAN = 1
    case reachableViaWiFi = 2

    /// Returns a localized string representation of the reachability status
    public var localizedDescription: String {
        switch self {
        case .notReachable:
            return NSLocalizedString("Not Reachable", tableName: "LWNetworking", comment: "")
        case .reachableViaWWAN:
            return NSLocalizedString("Reachable via WWAN", tableName: "LWNetworking", comment: "")
        case .reachableViaWiFi:
            return NSLocalizedString("Reachable via WiFi", tableName: "LWNetworking", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown", tableName: "LWNetworking", comment: "")
        }
    }
}

/// Notification name for reachability changes
public extension Notification.Name {
    static let networkReachabilityDidChange = Notification.Name("com.wodedata.networking.reachability.change")
}

/// User info key for reachability status in notifications
public let NetworkReachabilityNotificationStatusItem = "LWNetworkingReachabilityNotificationStatusItem"

/// LWNetworkReachabilityManager monitors the reachability of domains and addresses for both WWAN and WiFi network interfaces.
///
/// Reachability can be used to determine background information about why a network operation failed,
/// or to trigger a network operation retrying when a connection is established. It should not be used
/// to prevent a user from initiating a network request, as it's possible that an initial request may
/// be required to establish reachability.
///
/// - Warning: Instances of `LWNetworkReachabilityManager` must be started with `startMonitoring()` before reachability status can be determined.
public class LWNetworkReachabilityManager {

    // MARK: - Properties

    /// The current network reachability status
    private(set) public var networkReachabilityStatus: NetworkReachabilityStatus = .unknown {
        didSet {
            if oldValue != networkReachabilityStatus {
                notifyReachabilityStatusChange()
            }
        }
    }

    /// Whether or not the network is currently reachable
    public var isReachable: Bool {
        return isReachableViaWWAN || isReachableViaWiFi
    }

    /// Whether or not the network is currently reachable via WWAN
    public var isReachableViaWWAN: Bool {
        return networkReachabilityStatus == .reachableViaWWAN
    }

    /// Whether or not the network is currently reachable via WiFi
    public var isReachableViaWiFi: Bool {
        return networkReachabilityStatus == .reachableViaWiFi
    }

    private let networkReachability: SCNetworkReachability
    private var statusChangeBlock: ((NetworkReachabilityStatus) -> Void)?

    // MARK: - Initialization

    /// Returns the shared network reachability manager
    public static let shared: LWNetworkReachabilityManager = {
        return LWNetworkReachabilityManager()
    }()

    /// Creates and returns a network reachability manager with the default socket address
    public convenience init() {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        if #available(iOS 9.0, *) {
            var address = sockaddr_in6()
            address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            address.sin6_family = sa_family_t(AF_INET6)
            self.init(address: address)
        } else {
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            self.init(address: address)
        }
        #elseif os(macOS)
        if #available(macOS 10.11, *) {
            var address = sockaddr_in6()
            address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            address.sin6_family = sa_family_t(AF_INET6)
            self.init(address: address)
        } else {
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            self.init(address: address)
        }
        #else
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        self.init(address: address)
        #endif
    }

    /// Creates and returns a network reachability manager for the specified domain
    ///
    /// - Parameter domain: The domain used to evaluate network reachability
    public convenience init(domain: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, domain) else {
            fatalError("Failed to create reachability with domain: \(domain)")
        }
        self.init(reachability: reachability)
    }

    /// Creates and returns a network reachability manager for the socket address
    ///
    /// - Parameter address: The socket address used to evaluate network reachability
    public convenience init<T>(address: T) {
        var addr = address
        guard let reachability = withUnsafePointer(to: &addr, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            fatalError("Failed to create reachability with address")
        }
        self.init(reachability: reachability)
    }

    /// Initializes an instance of a network reachability manager from the specified reachability object
    ///
    /// - Parameter reachability: The reachability object to monitor
    public init(reachability: SCNetworkReachability) {
        self.networkReachability = reachability
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Monitoring

    /// Starts monitoring for changes in network reachability status
    public func startMonitoring() {
        stopMonitoring()

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: SCNetworkReachabilityCallBack = { (_, flags, info) in
            guard let info = info else { return }
            let manager = Unmanaged<LWNetworkReachabilityManager>.fromOpaque(info).takeUnretainedValue()
            let status = manager.networkReachabilityStatus(for: flags)

            DispatchQueue.main.async {
                manager.networkReachabilityStatus = status
                manager.statusChangeBlock?(status)
            }
        }

        if SCNetworkReachabilitySetCallback(networkReachability, callback, &context) {
            SCNetworkReachabilityScheduleWithRunLoop(networkReachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        }

        // Get initial status
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            var flags = SCNetworkReachabilityFlags()
            if SCNetworkReachabilityGetFlags(self.networkReachability, &flags) {
                let status = self.networkReachabilityStatus(for: flags)
                DispatchQueue.main.async {
                    self.networkReachabilityStatus = status
                    self.statusChangeBlock?(status)
                }
            }
        }
    }

    /// Stops monitoring for changes in network reachability status
    public func stopMonitoring() {
        SCNetworkReachabilityUnscheduleFromRunLoop(networkReachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }

    // MARK: - Status Change Callback

    /// Sets a callback to be executed when the network availability changes
    ///
    /// - Parameter block: A closure to be executed when the network availability changes
    public func setReachabilityStatusChangeBlock(_ block: @escaping (NetworkReachabilityStatus) -> Void) {
        self.statusChangeBlock = block
    }

    // MARK: - Helper Methods

    /// Returns a localized string representation of the current network reachability status
    public func localizedNetworkReachabilityStatusString() -> String {
        return networkReachabilityStatus.localizedDescription
    }

    private func networkReachabilityStatus(for flags: SCNetworkReachabilityFlags) -> NetworkReachabilityStatus {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectionAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectionAutomatically && !flags.contains(.interventionRequired)
        let isNetworkReachable = isReachable && (!needsConnection || canConnectWithoutUserInteraction)

        var status: NetworkReachabilityStatus = .unknown

        if !isNetworkReachable {
            status = .notReachable
        }
        #if os(iOS) && !targetEnvironment(macCatalyst)
        else if flags.contains(.isWWAN) {
            status = .reachableViaWWAN
        }
        #endif
        else {
            status = .reachableViaWiFi
        }

        return status
    }

    private func notifyReachabilityStatusChange() {
        let userInfo = [NetworkReachabilityNotificationStatusItem: networkReachabilityStatus.rawValue]
        NotificationCenter.default.post(name: .networkReachabilityDidChange, object: nil, userInfo: userInfo)
    }
}

#endif
