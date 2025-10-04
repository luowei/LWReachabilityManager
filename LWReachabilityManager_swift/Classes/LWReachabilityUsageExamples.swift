// LWReachabilityUsageExamples.swift
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

#if !os(watchOS)

// MARK: - Traditional Swift API Usage Examples

/// Example 1: Using the shared manager instance
func exampleBasicUsage() {
    let manager = LWNetworkReachabilityManager.shared

    // Start monitoring
    manager.startMonitoring()

    // Set up a callback for status changes
    manager.setReachabilityStatusChangeBlock { status in
        switch status {
        case .reachableViaWiFi:
            print("Network is reachable via WiFi")
        case .reachableViaWWAN:
            print("Network is reachable via WWAN (Cellular)")
        case .notReachable:
            print("Network is not reachable")
        case .unknown:
            print("Network status is unknown")
        }
    }

    // Check current status
    if manager.isReachable {
        print("Currently connected")
    } else {
        print("No connection")
    }
}

/// Example 2: Monitor specific domain
func exampleDomainMonitoring() {
    let manager = LWNetworkReachabilityManager(domain: "www.apple.com")

    manager.startMonitoring()

    manager.setReachabilityStatusChangeBlock { status in
        print("Reachability to www.apple.com: \(status.localizedDescription)")
    }
}

/// Example 3: Using NotificationCenter
func exampleNotificationObserver() {
    let manager = LWNetworkReachabilityManager.shared
    manager.startMonitoring()

    NotificationCenter.default.addObserver(
        forName: .networkReachabilityDidChange,
        object: nil,
        queue: .main
    ) { notification in
        if let statusValue = notification.userInfo?[NetworkReachabilityNotificationStatusItem] as? Int,
           let status = NetworkReachabilityStatus(rawValue: statusValue) {
            print("Network status changed via notification: \(status.localizedDescription)")
        }
    }
}

// MARK: - SwiftUI/Combine API Usage Examples

#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
import Combine

/// Example 4: SwiftUI View with StateObject
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct ExampleSwiftUIView: View {
    @StateObject private var reachability = NetworkReachabilityObserver.shared

    var body: some View {
        VStack(spacing: 20) {
            // Status indicator
            if reachability.isReachable {
                Label("Connected", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Label("Disconnected", systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
            }

            // Connection type
            if reachability.isReachableViaWiFi {
                Text("WiFi Connection")
            } else if reachability.isReachableViaWWAN {
                Text("Cellular Connection")
            }

            // Localized status
            Text(reachability.localizedStatusString())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onAppear {
            reachability.startMonitoring()
        }
        .onDisappear {
            reachability.stopMonitoring()
        }
    }
}

/// Example 5: Using the view modifier
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct ExampleViewModifier: View {
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Text("My App Content")
            .onNetworkReachabilityChange { status in
                if status == .notReachable {
                    alertMessage = "Network connection lost"
                    showAlert = true
                } else {
                    alertMessage = "Network connection restored"
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Network Status"), message: Text(alertMessage))
            }
    }
}

/// Example 6: Using Combine publishers
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
class ExampleViewModel: ObservableObject {
    @Published var connectionStatus: String = "Unknown"
    private var cancellables = Set<AnyCancellable>()
    private let reachability = NetworkReachabilityObserver.shared

    init() {
        setupObservers()
    }

    private func setupObservers() {
        // Start monitoring
        reachability.startMonitoring()

        // Observe status changes using Combine
        reachability.statusPublisher
            .map { status -> String in
                switch status {
                case .reachableViaWiFi:
                    return "Connected via WiFi"
                case .reachableViaWWAN:
                    return "Connected via Cellular"
                case .notReachable:
                    return "No Connection"
                case .unknown:
                    return "Unknown Connection"
                }
            }
            .assign(to: &$connectionStatus)

        // React to specific status changes
        reachability.statusPublisher
            .filter { $0 == .notReachable }
            .sink { _ in
                print("Connection lost - consider pausing network operations")
            }
            .store(in: &cancellables)

        // Observe when connection is restored
        reachability.statusPublisher
            .filter { $0 == .reachableViaWiFi || $0 == .reachableViaWWAN }
            .sink { _ in
                print("Connection restored - resume network operations")
            }
            .store(in: &cancellables)
    }

    deinit {
        reachability.stopMonitoring()
    }
}

/// Example 7: Custom reachability observer for specific domain
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
class APIReachabilityMonitor: ObservableObject {
    @Published var isAPIReachable = false
    private let observer: NetworkReachabilityObserver
    private var cancellables = Set<AnyCancellable>()

    init(apiDomain: String) {
        self.observer = NetworkReachabilityObserver(domain: apiDomain)

        observer.statusPublisher
            .map { $0 == .reachableViaWiFi || $0 == .reachableViaWWAN }
            .assign(to: &$isAPIReachable)

        observer.startMonitoring()
    }

    deinit {
        observer.stopMonitoring()
    }
}

#endif

// MARK: - UIKit Integration Examples

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// Example 8: UIKit ViewController integration
class ExampleViewController: UIViewController {
    private let reachabilityManager = LWNetworkReachabilityManager.shared
    private var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupReachability()
    }

    private func setupUI() {
        statusLabel = UILabel()
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupReachability() {
        reachabilityManager.startMonitoring()

        reachabilityManager.setReachabilityStatusChangeBlock { [weak self] status in
            self?.updateUI(for: status)
        }
    }

    private func updateUI(for status: NetworkReachabilityStatus) {
        switch status {
        case .reachableViaWiFi:
            statusLabel.text = "Connected via WiFi"
            statusLabel.textColor = .systemGreen
        case .reachableViaWWAN:
            statusLabel.text = "Connected via Cellular"
            statusLabel.textColor = .systemGreen
        case .notReachable:
            statusLabel.text = "No Connection"
            statusLabel.textColor = .systemRed
        case .unknown:
            statusLabel.text = "Unknown"
            statusLabel.textColor = .systemGray
        }
    }

    deinit {
        reachabilityManager.stopMonitoring()
    }
}

#endif

#endif
