# LWReachabilityManager Swift版本使用说明

## 概述

LWReachabilityManager提供了Swift版本的实现，专门为使用Swift开发的项目优化，提供更现代化的网络状态监测功能。

## 安装

### CocoaPods

在你的`Podfile`中添加：

```ruby
pod 'LWReachabilityManager_swift'
```

然后运行：

```bash
pod install
```

## 要求

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## Swift版本包含的功能

Swift版本包含以下组件：

- `LWNetworkReachabilityManager.swift` - 网络可达性管理器
- `NetworkReachabilityObserver.swift` - 网络状态观察者
- `NetworkReachabilityView.swift` - 网络状态视图
- `LWReachabilityUsageExamples.swift` - 使用示例

## 使用示例

### 基础用法

```swift
import LWReachabilityManager_swift

// 监听网络状态
LWNetworkReachabilityManager.shared.startMonitoring { status in
    switch status {
    case .notReachable:
        print("网络不可用")
    case .reachableViaWiFi:
        print("WiFi连接")
    case .reachableViaWWAN:
        print("蜂窝网络连接")
    }
}

// 停止监听
LWNetworkReachabilityManager.shared.stopMonitoring()
```

### SwiftUI集成

```swift
import SwiftUI
import LWReachabilityManager_swift

struct ContentView: View {
    @StateObject var reachability = NetworkReachabilityObserver()

    var body: some View {
        VStack {
            if reachability.isReachable {
                Text("网络已连接")
            } else {
                Text("网络不可用")
            }
        }
    }
}
```

### Combine支持

```swift
import Combine
import LWReachabilityManager_swift

class ViewModel: ObservableObject {
    @Published var isConnected = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        LWNetworkReachabilityManager.shared.statusPublisher
            .sink { [weak self] status in
                self?.isConnected = status != .notReachable
            }
            .store(in: &cancellables)
    }
}
```

## 与Objective-C版本的区别

- Swift版本要求iOS 13.0+（Objective-C版本支持iOS 8.0+）
- Swift版本提供了SwiftUI和Combine支持
- Swift版本使用现代Swift语法和属性包装器
- 提供更类型安全的API

## 注意事项

- 如果你的项目同时使用Objective-C和Swift，可以同时安装`LWReachabilityManager`和`LWReachabilityManager_swift`
- Swift版本与Objective-C版本可以共存，互不影响
- 建议在App启动时开始监听网络状态

## 许可证

LWReachabilityManager_swift遵循MIT许可证。详见LICENSE文件。
