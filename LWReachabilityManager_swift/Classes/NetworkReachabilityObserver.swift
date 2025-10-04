// NetworkReachabilityObserver.swift
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
import Combine

#if !os(watchOS)

/// A SwiftUI/Combine-compatible wrapper for LWNetworkReachabilityManager
///
/// This class conforms to `ObservableObject` and can be used directly in SwiftUI views.
/// It provides a reactive interface to network reachability status using Combine.
///
/// Example usage in SwiftUI:
/// ```swift
/// @StateObject private var reachability = NetworkReachabilityObserver.shared
///
/// var body: some View {
///     VStack {
///         if reachability.isReachable {
///             Text("Connected")
///         } else {
///             Text("No Connection")
///         }
///     }
///     .onAppear {
///         reachability.startMonitoring()
///     }
/// }
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public class NetworkReachabilityObserver: ObservableObject {

    // MARK: - Published Properties

    /// The current network reachability status (published for SwiftUI)
    @Published public private(set) var status: NetworkReachabilityStatus = .unknown

    /// Whether or not the network is currently reachable
    @Published public private(set) var isReachable: Bool = false

    /// Whether or not the network is currently reachable via WWAN
    @Published public private(set) var isReachableViaWWAN: Bool = false

    /// Whether or not the network is currently reachable via WiFi
    @Published public private(set) var isReachableViaWiFi: Bool = false

    // MARK: - Properties

    private let manager: LWNetworkReachabilityManager
    private var cancellables = Set<AnyCancellable>()

    /// Publisher that emits network reachability status changes
    public let statusPublisher: AnyPublisher<NetworkReachabilityStatus, Never>

    private let statusSubject = PassthroughSubject<NetworkReachabilityStatus, Never>()

    // MARK: - Initialization

    /// Returns the shared network reachability observer
    public static let shared = NetworkReachabilityObserver()

    /// Creates and returns a network reachability observer with the default socket address
    public convenience init() {
        self.init(manager: LWNetworkReachabilityManager())
    }

    /// Creates and returns a network reachability observer for the specified domain
    ///
    /// - Parameter domain: The domain used to evaluate network reachability
    public convenience init(domain: String) {
        self.init(manager: LWNetworkReachabilityManager(domain: domain))
    }

    /// Creates and returns a network reachability observer for the socket address
    ///
    /// - Parameter address: The socket address used to evaluate network reachability
    public convenience init<T>(address: T) {
        self.init(manager: LWNetworkReachabilityManager(address: address))
    }

    /// Initializes an instance with a specific reachability manager
    ///
    /// - Parameter manager: The reachability manager to use
    public init(manager: LWNetworkReachabilityManager) {
        self.manager = manager
        self.statusPublisher = statusSubject.eraseToAnyPublisher()

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        manager.setReachabilityStatusChangeBlock { [weak self] status in
            guard let self = self else { return }
            self.status = status
            self.isReachable = self.manager.isReachable
            self.isReachableViaWWAN = self.manager.isReachableViaWWAN
            self.isReachableViaWiFi = self.manager.isReachableViaWiFi
            self.statusSubject.send(status)
        }

        // Also listen to notifications
        NotificationCenter.default.publisher(for: .networkReachabilityDidChange)
            .compactMap { notification -> NetworkReachabilityStatus? in
                guard let statusValue = notification.userInfo?[NetworkReachabilityNotificationStatusItem] as? Int,
                      let status = NetworkReachabilityStatus(rawValue: statusValue) else {
                    return nil
                }
                return status
            }
            .sink { [weak self] status in
                guard let self = self else { return }
                self.status = status
                self.isReachable = self.manager.isReachable
                self.isReachableViaWWAN = self.manager.isReachableViaWWAN
                self.isReachableViaWiFi = self.manager.isReachableViaWiFi
            }
            .store(in: &cancellables)
    }

    // MARK: - Monitoring

    /// Starts monitoring for changes in network reachability status
    public func startMonitoring() {
        manager.startMonitoring()
    }

    /// Stops monitoring for changes in network reachability status
    public func stopMonitoring() {
        manager.stopMonitoring()
    }

    // MARK: - Helper Methods

    /// Returns a localized string representation of the current network reachability status
    public func localizedStatusString() -> String {
        return status.localizedDescription
    }
}

#endif
