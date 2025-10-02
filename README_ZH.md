# LWReachabilityManager

[![CI Status](https://img.shields.io/travis/luowei/LWReachabilityManager.svg?style=flat)](https://travis-ci.org/luowei/LWReachabilityManager)
[![Version](https://img.shields.io/cocoapods/v/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)
[![License](https://img.shields.io/cocoapods/l/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)
[![Platform](https://img.shields.io/cocoapods/p/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)

## 简介

LWReachabilityManager 是一个轻量级的 iOS 网络可达性监控库，用于监控设备的网络连接状态。它可以检测当前网络是否可用，以及网络连接类型（WiFi 或移动网络 WWAN）。

该库基于 Apple 的 SystemConfiguration 框架，提供了简单易用的 API 来监控网络状态变化。

## 功能特性

- 实时监控网络可达性状态
- 区分 WiFi 和移动网络（WWAN）连接
- 支持域名和 IP 地址的可达性检测
- 提供回调 Block 和通知两种方式监听网络状态变化
- 单例模式，方便全局使用
- 支持 iOS 8.0 及以上版本
- 线程安全，自动在主线程回调

## 网络状态类型

LWReachabilityManager 提供以下四种网络状态：

```objective-c
typedef NS_ENUM(NSInteger, LWNetworkReachabilityStatus) {
    LWNetworkReachabilityStatusUnknown          = -1,  // 未知状态
    LWNetworkReachabilityStatusNotReachable     = 0,   // 网络不可达
    LWNetworkReachabilityStatusReachableViaWWAN = 1,   // 通过移动网络可达
    LWNetworkReachabilityStatusReachableViaWiFi = 2,   // 通过 WiFi 可达
};
```

## 系统要求

- iOS 8.0 或更高版本
- 需要导入 `SystemConfiguration.framework`

## 安装方式

### CocoaPods

LWReachabilityManager 支持通过 [CocoaPods](https://cocoapods.org) 安装。在 Podfile 中添加以下内容：

```ruby
pod 'LWReachabilityManager'
```

然后运行：

```bash
pod install
```

### Carthage

在 Cartfile 中添加：

```ruby
github "luowei/LWReachabilityManager"
```

然后运行：

```bash
carthage update
```

## 使用方法

### 基础用法

#### 1. 导入头文件

```objective-c
#import <LWReachabilityManager/LWNetworkReachabilityManager.h>
```

#### 2. 使用单例监控网络状态

```objective-c
// 设置网络状态变化回调
__weak typeof(self) weakSelf = self;
[[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    switch (status) {
        case LWNetworkReachabilityStatusUnknown:
            NSLog(@"网络状态未知");
            break;
        case LWNetworkReachabilityStatusNotReachable:
            NSLog(@"网络不可达");
            break;
        case LWNetworkReachabilityStatusReachableViaWWAN:
            NSLog(@"通过移动网络连接");
            break;
        case LWNetworkReachabilityStatusReachableViaWiFi:
            NSLog(@"通过 WiFi 连接");
            break;
    }
    weakSelf.networkReachabilityStatus = status;
}];

// 开始监控
[[LWNetworkReachabilityManager sharedManager] startMonitoring];
```

#### 3. 检查当前网络状态

```objective-c
// 检查网络是否可达
BOOL isReachable = [[LWNetworkReachabilityManager sharedManager] isReachable];

// 检查是否通过 WiFi 连接
BOOL isReachableViaWiFi = [[LWNetworkReachabilityManager sharedManager] isReachableViaWiFi];

// 检查是否通过移动网络连接
BOOL isReachableViaWWAN = [[LWNetworkReachabilityManager sharedManager] isReachableViaWWAN];

// 获取当前网络状态
LWNetworkReachabilityStatus status = [[LWNetworkReachabilityManager sharedManager] networkReachabilityStatus];

// 获取本地化的网络状态描述
NSString *statusString = [[LWNetworkReachabilityManager sharedManager] localizedNetworkReachabilityStatusString];
```

#### 4. 停止监控

```objective-c
[[LWNetworkReachabilityManager sharedManager] stopMonitoring];
```

### 高级用法

#### 监控特定域名的可达性

```objective-c
LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager managerForDomain:@"www.apple.com"];
[manager setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    NSLog(@"Apple 网站可达性状态: %@", LWStringFromNetworkReachabilityStatus(status));
}];
[manager startMonitoring];
```

#### 监控特定 IP 地址的可达性

```objective-c
struct sockaddr_in address;
bzero(&address, sizeof(address));
address.sin_len = sizeof(address);
address.sin_family = AF_INET;
inet_aton("8.8.8.8", &address.sin_addr);

LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager managerForAddress:&address];
[manager setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    NSLog(@"DNS 服务器可达性状态: %@", LWStringFromNetworkReachabilityStatus(status));
}];
[manager startMonitoring];
```

#### 使用通知方式监听网络状态变化

```objective-c
// 注册通知
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(reachabilityStatusChanged:)
                                             name:LWNetworkingReachabilityDidChangeNotification
                                           object:nil];

// 开始监控
[[LWNetworkReachabilityManager sharedManager] startMonitoring];

// 通知回调方法
- (void)reachabilityStatusChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *statusNumber = userInfo[LWNetworkingReachabilityNotificationStatusItem];
    LWNetworkReachabilityStatus status = [statusNumber integerValue];
    NSLog(@"网络状态变化: %@", LWStringFromNetworkReachabilityStatus(status));
}

// 不要忘记在 dealloc 中移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
```

## API 文档

### 类方法

#### 单例方法

```objective-c
+ (instancetype)sharedManager;
```

返回全局共享的网络可达性管理器实例。

#### 创建管理器实例

```objective-c
+ (instancetype)manager;
```

创建并返回使用默认 socket 地址的网络可达性管理器。

```objective-c
+ (instancetype)managerForDomain:(NSString *)domain;
```

创建并返回监控指定域名的网络可达性管理器。

**参数：**
- `domain`: 用于评估网络可达性的域名

```objective-c
+ (instancetype)managerForAddress:(const void *)address;
```

创建并返回监控指定 socket 地址的网络可达性管理器。

**参数：**
- `address`: 用于评估网络可达性的 socket 地址（sockaddr_in 或 sockaddr_in6）

### 实例方法

#### 初始化方法

```objective-c
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability;
```

使用指定的可达性对象初始化管理器实例（指定初始化方法）。

#### 监控控制

```objective-c
- (void)startMonitoring;
```

开始监控网络可达性状态变化。

```objective-c
- (void)stopMonitoring;
```

停止监控网络可达性状态变化。

#### 设置回调

```objective-c
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(LWNetworkReachabilityStatus status))block;
```

设置网络状态变化时的回调 Block。

**参数：**
- `block`: 网络状态变化时执行的 Block，参数为新的网络状态

#### 获取状态描述

```objective-c
- (NSString *)localizedNetworkReachabilityStatusString;
```

返回当前网络可达性状态的本地化字符串描述。

### 属性

```objective-c
@property (readonly, nonatomic, assign) LWNetworkReachabilityStatus networkReachabilityStatus;
```

当前的网络可达性状态。

```objective-c
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;
```

网络当前是否可达。

```objective-c
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
```

网络当前是否通过 WWAN（移动网络）可达。

```objective-c
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;
```

网络当前是否通过 WiFi 可达。

### 常量

#### 通知名称

```objective-c
FOUNDATION_EXPORT NSString * const LWNetworkingReachabilityDidChangeNotification;
```

网络可达性状态变化时发送的通知。userInfo 字典中包含 `LWNetworkingReachabilityNotificationStatusItem` 键，对应的值是表示当前网络状态的 NSNumber 对象。

```objective-c
FOUNDATION_EXPORT NSString * const LWNetworkingReachabilityNotificationStatusItem;
```

通知 userInfo 字典中的键，用于获取网络状态值。

#### 工具函数

```objective-c
FOUNDATION_EXPORT NSString * LWStringFromNetworkReachabilityStatus(LWNetworkReachabilityStatus status);
```

返回网络可达性状态的本地化字符串表示。

## 注意事项

1. **必须先调用 `startMonitoring`**：在检查网络状态之前，必须先调用 `startMonitoring` 方法开始监控，否则无法获取准确的网络状态。

2. **不建议阻止用户操作**：不应该使用可达性检查来阻止用户发起网络请求。Apple 建议只将其用于：
   - 判断网络操作失败的背景原因
   - 在网络连接建立时触发重试操作

3. **回调在主线程执行**：所有的状态变化回调和通知都会在主线程上执行，可以直接更新 UI。

4. **资源管理**：当不再需要监控时，应该调用 `stopMonitoring` 方法停止监控，释放系统资源。

5. **SystemConfiguration 框架**：使用本库需要在项目中链接 `SystemConfiguration.framework`。

## 使用场景

### 场景 1：应用启动时检查网络

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 设置网络监控
    [[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
        if (status == LWNetworkReachabilityStatusNotReachable) {
            // 显示无网络提示
            [self showNoNetworkAlert];
        }
    }];
    [[LWNetworkReachabilityManager sharedManager] startMonitoring];

    return YES;
}
```

### 场景 2：网络请求失败后的处理

```objective-c
- (void)loadDataFromServer {
    if (![[LWNetworkReachabilityManager sharedManager] isReachable]) {
        // 网络不可达，显示提示
        [self showMessage:@"网络不可用，请检查网络设置"];
        return;
    }

    // 执行网络请求
    [self performNetworkRequest];
}
```

### 场景 3：根据网络类型调整策略

```objective-c
- (void)downloadLargeFile {
    LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager sharedManager];

    if ([manager isReachableViaWiFi]) {
        // WiFi 环境，可以下载高清视频
        [self downloadHighQualityVideo];
    } else if ([manager isReachableViaWWAN]) {
        // 移动网络，提示用户
        [self showAlert:@"当前使用移动网络，是否继续下载？" completion:^(BOOL confirmed) {
            if (confirmed) {
                [self downloadStandardQualityVideo];
            }
        }];
    } else {
        // 无网络连接
        [self showMessage:@"网络不可用"];
    }
}
```

## 示例项目

项目中包含了完整的示例代码，演示了如何使用 LWReachabilityManager。

运行示例项目：

```bash
cd Example
pod install
open LWReachabilityManager.xcworkspace
```

## 技术实现

LWReachabilityManager 基于 Apple 的 SystemConfiguration 框架实现，主要使用了以下技术：

- `SCNetworkReachabilityRef`：用于创建和管理可达性检查对象
- `SCNetworkReachabilitySetCallback`：设置状态变化回调
- `SCNetworkReachabilityScheduleWithRunLoop`：将监控添加到运行循环
- `SCNetworkReachabilityFlags`：分析网络状态标志位

库的实现确保了：
- 线程安全
- 自动内存管理（ARC）
- 回调顺序与状态变化顺序一致
- 资源的正确释放

## 版本历史

- **1.0.0**：初始版本发布

## 作者

luowei - luowei@wodedata.com

## 许可证

LWReachabilityManager 使用 MIT 许可证。详细信息请查看 LICENSE 文件。

```
MIT License

Copyright (c) 2019 luowei

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 参考资料

- [Apple Reachability Sample Code](https://developer.apple.com/library/ios/samplecode/reachability/)
- [SystemConfiguration Framework](https://developer.apple.com/documentation/systemconfiguration)
- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - 本库参考了 AFNetworking 的实现

## 常见问题

### Q: 为什么获取的状态总是 Unknown？

A: 请确保在检查状态之前调用了 `startMonitoring` 方法。只有开始监控后，管理器才能获取和更新网络状态。

### Q: 可以在后台线程使用吗？

A: 可以在任意线程调用 API，但状态变化的回调始终在主线程执行，方便直接更新 UI。

### Q: 需要在每个页面都创建实例吗？

A: 不需要。推荐使用 `sharedManager` 单例，在应用启动时开始监控，全局共享使用。

### Q: 如何判断是 4G 还是 5G？

A: 本库只区分 WiFi 和 WWAN（移动网络），不区分具体的移动网络制式（3G/4G/5G）。如需更详细的网络信息，需要使用 CoreTelephony 框架。

### Q: 监控会消耗很多资源吗？

A: 不会。监控基于系统回调机制，只在网络状态变化时才会触发回调，平时几乎不消耗资源。
