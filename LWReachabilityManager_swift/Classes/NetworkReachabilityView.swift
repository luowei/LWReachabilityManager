// NetworkReachabilityView.swift
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

#if canImport(SwiftUI) && !os(watchOS)
import SwiftUI

/// A SwiftUI view modifier that observes network reachability status
///
/// This view modifier can be used to react to network status changes in any SwiftUI view.
///
/// Example usage:
/// ```swift
/// MyView()
///     .onNetworkReachabilityChange { status in
///         print("Network status changed to: \(status.localizedDescription)")
///     }
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct NetworkReachabilityModifier: ViewModifier {
    @StateObject private var observer = NetworkReachabilityObserver.shared
    let action: (NetworkReachabilityStatus) -> Void

    public func body(content: Content) -> some View {
        content
            .onAppear {
                observer.startMonitoring()
            }
            .onDisappear {
                observer.stopMonitoring()
            }
            .onChange(of: observer.status) { newStatus in
                action(newStatus)
            }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View {
    /// Adds a modifier to monitor network reachability changes
    ///
    /// - Parameter action: A closure that is called when the network status changes
    /// - Returns: A view that monitors network reachability
    func onNetworkReachabilityChange(_ action: @escaping (NetworkReachabilityStatus) -> Void) -> some View {
        modifier(NetworkReachabilityModifier(action: action))
    }
}

/// A sample SwiftUI view that demonstrates network reachability monitoring
///
/// This view shows the current network status and provides a visual indicator
/// of the connection state.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct NetworkReachabilityStatusView: View {
    @StateObject private var observer = NetworkReachabilityObserver.shared

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            // Status Icon
            statusIcon
                .font(.system(size: 60))
                .foregroundColor(statusColor)

            // Status Text
            Text(observer.localizedStatusString())
                .font(.headline)
                .foregroundColor(statusColor)

            // Connection Details
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(title: "Reachable", value: observer.isReachable)
                DetailRow(title: "WiFi", value: observer.isReachableViaWiFi)
                DetailRow(title: "WWAN", value: observer.isReachableViaWWAN)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            observer.startMonitoring()
        }
        .onDisappear {
            observer.stopMonitoring()
        }
    }

    private var statusIcon: some View {
        Group {
            switch observer.status {
            case .reachableViaWiFi:
                Image(systemName: "wifi")
            case .reachableViaWWAN:
                Image(systemName: "antenna.radiowaves.left.and.right")
            case .notReachable:
                Image(systemName: "wifi.slash")
            case .unknown:
                Image(systemName: "questionmark.circle")
            }
        }
    }

    private var statusColor: Color {
        switch observer.status {
        case .reachableViaWiFi, .reachableViaWWAN:
            return .green
        case .notReachable:
            return .red
        case .unknown:
            return .gray
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct DetailRow: View {
    let title: String
    let value: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Image(systemName: value ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(value ? .green : .red)
        }
    }
}

// MARK: - Preview

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct NetworkReachabilityStatusView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkReachabilityStatusView()
    }
}

#endif
