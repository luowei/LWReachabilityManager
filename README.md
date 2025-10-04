# LWReachabilityManager

[![CI Status](https://img.shields.io/travis/luowei/LWReachabilityManager.svg?style=flat)](https://travis-ci.org/luowei/LWReachabilityManager)
[![Version](https://img.shields.io/cocoapods/v/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)
[![License](https://img.shields.io/cocoapods/l/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)
[![Platform](https://img.shields.io/cocoapods/p/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)

[English](./README.md) | [中文版](./README_ZH.md)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Network Status](#network-status)
- [API Reference](#api-reference)
- [Best Practices](#best-practices)
- [Use Cases](#use-cases)
- [Important Notes](#important-notes)
- [Example Project](#example-project)
- [Author](#author)
- [License](#license)

---

## Overview

LWReachabilityManager is a lightweight and easy-to-use network reachability monitoring library for iOS and macOS. Built on Apple's SystemConfiguration framework, it provides a simple API to monitor network connectivity status and notifies your app when network conditions change.

The library helps you detect whether the device is connected to the internet and distinguishes between WiFi and cellular (WWAN) connections, enabling you to optimize your app's behavior based on the available network type.

---

## Features

- **Real-time Network Monitoring**: Continuously monitors network reachability status changes
- **WiFi & WWAN Detection**: Precisely distinguishes between WiFi and WWAN (cellular) connections including 3G, 4G, 5G, LTE, and EDGE
- **Comprehensive Network Status**: Detects four distinct states - Unknown, Not Reachable, Reachable via WWAN, and Reachable via WiFi
- **Flexible Monitoring Options**: Monitor default network, specific domains (e.g., api.example.com), or custom socket addresses (e.g., 8.8.8.8)
- **Block-based Callbacks**: Simple and intuitive callback blocks executed when network status changes
- **NSNotification Support**: Posts notifications for network status changes, enabling decoupled architecture patterns
- **Thread-safe**: All callbacks are automatically dispatched to the main queue for safe UI updates
- **KVO Support**: Network status properties are Key-Value Observing compliant
- **Lightweight & Efficient**: Minimal overhead with optimized implementation based on Apple's SystemConfiguration framework
- **Easy Integration**: Simple API with singleton pattern for global access

---

## Requirements

- iOS 7.0+ / macOS 10.9+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 7.0+
- SystemConfiguration.framework

---

## Installation

### CocoaPods

LWReachabilityManager is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'LWReachabilityManager'
```

For Swift version, use:

```ruby
pod 'LWReachabilityManager_swift'
```

See [Swift Version Documentation](README_SWIFT_VERSION.md) for more details.

Then run:

```bash
pod install
```

### Carthage

Add the following to your Cartfile:

```ruby
github "luowei/LWReachabilityManager"
```

Then run:

```bash
carthage update
```

---

## Quick Start

```Objective-C
#import <LWReachabilityManager/LWNetworkReachabilityManager.h>

// Set up monitoring
[[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    switch (status) {
        case LWNetworkReachabilityStatusReachableViaWiFi:
            NSLog(@"WiFi connected");
            break;
        case LWNetworkReachabilityStatusReachableViaWWAN:
            NSLog(@"Cellular connected");
            break;
        case LWNetworkReachabilityStatusNotReachable:
            NSLog(@"No connection");
            break;
        case LWNetworkReachabilityStatusUnknown:
        default:
            NSLog(@"Unknown status");
            break;
    }
}];

// Start monitoring
[[LWNetworkReachabilityManager sharedManager] startMonitoring];

// Check current status anytime
BOOL isWiFi = [[LWNetworkReachabilityManager sharedManager] isReachableViaWiFi];
BOOL isCellular = [[LWNetworkReachabilityManager sharedManager] isReachableViaWWAN];
```

---

## Network Status

LWReachabilityManager provides four distinct network states with comprehensive connection type detection:

- **`LWNetworkReachabilityStatusUnknown` (-1)**: Network reachability status is unknown
  - Occurs before monitoring starts or during initialization
  - Should prompt status verification after starting monitoring

- **`LWNetworkReachabilityStatusNotReachable` (0)**: Network is not reachable
  - No network connection available (Airplane mode, no signal, etc.)
  - Neither WiFi nor cellular data is accessible

- **`LWNetworkReachabilityStatusReachableViaWWAN` (1)**: Network is reachable via WWAN (Wireless Wide Area Network)
  - Cellular/mobile data connections including:
    - 5G (5th generation mobile network)
    - 4G/LTE (Long-Term Evolution)
    - 3G (UMTS, HSPA, HSPA+)
    - 2G (EDGE, GPRS)
  - Useful for prompting users about data usage or adjusting content quality

- **`LWNetworkReachabilityStatusReachableViaWiFi` (2)**: Network is reachable via WiFi
  - Connected to WiFi network (802.11 a/b/g/n/ac/ax)
  - Optimal for data-intensive operations like video streaming or large downloads
  - Generally indicates faster and more stable connection

### Status Enum

```objective-c
typedef NS_ENUM(NSInteger, LWNetworkReachabilityStatus) {
    LWNetworkReachabilityStatusUnknown          = -1,  // Status unknown
    LWNetworkReachabilityStatusNotReachable     = 0,   // Not reachable
    LWNetworkReachabilityStatusReachableViaWWAN = 1,   // Reachable via cellular
    LWNetworkReachabilityStatusReachableViaWiFi = 2,   // Reachable via WiFi
};
```

---

## Usage

### Basic Monitoring Setup

The most common use case is monitoring the default network connection:

```Objective-C
#import <LWReachabilityManager/LWNetworkReachabilityManager.h>

// Start monitoring with callback block
__weak typeof(self) weakSelf = self;
[[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    __strong typeof(weakSelf) strongSelf = weakSelf;

    switch (status) {
        case LWNetworkReachabilityStatusNotReachable:
            NSLog(@"Network not reachable");
            // Update UI to show offline mode
            break;

        case LWNetworkReachabilityStatusReachableViaWWAN:
            NSLog(@"Network reachable via WWAN (cellular)");
            // Maybe warn user about cellular data usage
            break;

        case LWNetworkReachabilityStatusReachableViaWiFi:
            NSLog(@"Network reachable via WiFi");
            // Optimal connection for data-intensive operations
            break;

        case LWNetworkReachabilityStatusUnknown:
        default:
            NSLog(@"Network status unknown");
            break;
    }
}];

[[LWNetworkReachabilityManager sharedManager] startMonitoring];
```

### Checking Current Network Status

You can query the current network status at any time:

```Objective-C
LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager sharedManager];

// Check if network is reachable
BOOL isReachable = manager.isReachable;

// Check specific connection types
BOOL isReachableViaWWAN = manager.isReachableViaWWAN;
BOOL isReachableViaWiFi = manager.isReachableViaWiFi;

// Get current status
LWNetworkReachabilityStatus status = manager.networkReachabilityStatus;

// Get localized status description
NSString *statusDescription = [manager localizedNetworkReachabilityStatusString];
NSLog(@"Current network status: %@", statusDescription);
```

### WiFi vs WWAN Detection

Distinguish between WiFi and cellular connections to optimize user experience:

```Objective-C
LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager sharedManager];

// Method 1: Using convenience properties
if (manager.isReachableViaWiFi) {
    NSLog(@"Connected via WiFi - ideal for high-quality content");
    // Enable HD video streaming
    [self enableHDVideoQuality];
} else if (manager.isReachableViaWWAN) {
    NSLog(@"Connected via cellular network - optimize data usage");
    // Use standard quality to save data
    [self enableStandardVideoQuality];
    // Optionally warn user about cellular data usage
    [self showCellularDataWarningIfNeeded];
} else {
    NSLog(@"No network connection available");
    // Show offline mode or cached content
    [self showOfflineMode];
}

// Method 2: Using status enum for comprehensive handling
switch (manager.networkReachabilityStatus) {
    case LWNetworkReachabilityStatusReachableViaWiFi:
        NSLog(@"WiFi connection detected - 802.11 a/b/g/n/ac/ax");
        [self loadHighResolutionImages];
        [self enableAutomaticBackups];
        break;

    case LWNetworkReachabilityStatusReachableViaWWAN:
        NSLog(@"Cellular connection detected - 2G/3G/4G/5G");
        [self loadOptimizedImages];
        [self disableAutomaticBackups];
        // Warn user for large downloads
        [self confirmBeforeLargeDownloads];
        break;

    case LWNetworkReachabilityStatusNotReachable:
        NSLog(@"Network not reachable - offline mode");
        [self showCachedContentOnly];
        [self disableNetworkFeatures];
        break;

    case LWNetworkReachabilityStatusUnknown:
        NSLog(@"Network status unknown - waiting for status");
        [self showLoadingIndicator];
        break;
}
```

### Real-time WiFi/WWAN Monitoring

Monitor network type changes in real-time (e.g., when user switches from WiFi to cellular):

```Objective-C
__weak typeof(self) weakSelf = self;
[[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    __strong typeof(weakSelf) strongSelf = weakSelf;

    if (status == LWNetworkReachabilityStatusReachableViaWiFi) {
        // Switched to WiFi - resume paused downloads
        NSLog(@"Switched to WiFi connection");
        [strongSelf resumeLargeDownloads];
        [strongSelf syncDataWithServer];
    }
    else if (status == LWNetworkReachabilityStatusReachableViaWWAN) {
        // Switched to cellular - pause large downloads
        NSLog(@"Switched to cellular connection");
        [strongSelf pauseLargeDownloads];
        [strongSelf showDataUsageAlert:@"You're now on cellular data. Large downloads have been paused."];
    }
    else if (status == LWNetworkReachabilityStatusNotReachable) {
        // Lost connection - save current state
        NSLog(@"Network connection lost");
        [strongSelf saveCurrentState];
        [strongSelf showOfflineNotification];
    }
}];

[[LWNetworkReachabilityManager sharedManager] startMonitoring];
```

### Monitoring Specific Domain

Monitor reachability of a specific domain:

```Objective-C
LWNetworkReachabilityManager *domainManager = [LWNetworkReachabilityManager managerForDomain:@"www.apple.com"];

[domainManager setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    if (status != LWNetworkReachabilityStatusNotReachable) {
        NSLog(@"apple.com is reachable");
    } else {
        NSLog(@"apple.com is not reachable");
    }
}];

[domainManager startMonitoring];
```

### Using NSNotification

For a more decoupled architecture, you can observe network changes via notifications:

```Objective-C
// Register for notifications
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(reachabilityDidChange:)
                                             name:LWNetworkingReachabilityDidChangeNotification
                                           object:nil];

// Start monitoring
[[LWNetworkReachabilityManager sharedManager] startMonitoring];

// Notification handler
- (void)reachabilityDidChange:(NSNotification *)notification {
    NSNumber *statusNumber = notification.userInfo[LWNetworkingReachabilityNotificationStatusItem];
    LWNetworkReachabilityStatus status = [statusNumber integerValue];

    NSLog(@"Network status changed to: %@", LWStringFromNetworkReachabilityStatus(status));
}

// Don't forget to remove observer
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                     name:LWNetworkingReachabilityDidChangeNotification
                                                   object:nil];
}
```

### Stop Monitoring

When you no longer need to monitor network status:

```Objective-C
[[LWNetworkReachabilityManager sharedManager] stopMonitoring];
```

### Advanced Usage

#### Custom Socket Address

Monitor reachability using a custom socket address:

```Objective-C
struct sockaddr_in address;
bzero(&address, sizeof(address));
address.sin_len = sizeof(address);
address.sin_family = AF_INET;
inet_aton("8.8.8.8", &address.sin_addr); // Google DNS

LWNetworkReachabilityManager *customManager = [LWNetworkReachabilityManager managerForAddress:&address];
[customManager startMonitoring];
```

#### Create Independent Manager

Instead of using the shared manager, create your own instance:

```Objective-C
LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager manager];
[manager setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    // Handle status change
}];
[manager startMonitoring];
```

---

## Use Cases

### Use Case 1: Video Streaming App

Adjust video quality based on connection type:

```Objective-C
- (void)playVideo:(NSURL *)videoURL {
    LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager sharedManager];

    if (manager.isReachableViaWiFi) {
        // WiFi: Stream 4K or 1080p HD video
        [self playVideoAtQuality:VideoQuality4K fromURL:videoURL];
        NSLog(@"Streaming 4K video over WiFi");
    }
    else if (manager.isReachableViaWWAN) {
        // Cellular: Offer quality options to user
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cellular Data"
                                                                       message:@"You're using cellular data. Choose video quality:"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"HD (uses more data)"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
            [self playVideoAtQuality:VideoQualityHD fromURL:videoURL];
        }]];

        [alert addAction:[UIAlertAction actionWithTitle:@"Standard (recommended)"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
            [self playVideoAtQuality:VideoQualitySD fromURL:videoURL];
        }]];

        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];

        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        // No connection: Show error
        [self showError:@"No internet connection. Please check your network settings."];
    }
}
```

### Use Case 2: Photo Backup App

Automatically backup photos only on WiFi:

```Objective-C
- (void)setupPhotoBackup {
    __weak typeof(self) weakSelf = self;

    [[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (status == LWNetworkReachabilityStatusReachableViaWiFi) {
            // WiFi detected: Start automatic backup
            if (strongSelf.hasUnbackedUpPhotos) {
                NSLog(@"WiFi connected. Starting automatic photo backup...");
                [strongSelf startPhotoBackup];
            }
        }
        else if (status == LWNetworkReachabilityStatusReachableViaWWAN) {
            // Cellular: Pause backup, save cellular data
            if (strongSelf.isBackingUp) {
                NSLog(@"Switched to cellular. Pausing photo backup to save data...");
                [strongSelf pausePhotoBackup];
                [strongSelf showNotification:@"Photo backup paused. Will resume on WiFi."];
            }
        }
    }];

    [[LWNetworkReachabilityManager sharedManager] startMonitoring];
}
```

### Use Case 3: E-commerce App

Handle network changes during checkout:

```Objective-C
- (void)processCheckout {
    // Monitor network during checkout process
    __weak typeof(self) weakSelf = self;

    [[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (status == LWNetworkReachabilityStatusNotReachable) {
            // Connection lost during checkout
            [strongSelf showError:@"Connection lost. Your order has been saved and will be processed when connection is restored."];
            [strongSelf saveOrderToLocalDatabase];
        }
        else if (status != LWNetworkReachabilityStatusUnknown) {
            // Connection restored
            if (strongSelf.hasPendingOrder) {
                NSLog(@"Connection restored. Resuming checkout process...");
                [strongSelf resumeCheckoutProcess];
            }
        }
    }];

    // Check current status before starting
    LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager sharedManager];

    if (manager.isReachable) {
        [self submitOrder];
    } else {
        [self showError:@"No internet connection. Please check your network and try again."];
    }
}
```

### Use Case 4: News App with Smart Loading

Load content intelligently based on network type:

```Objective-C
- (void)loadArticles {
    LWNetworkReachabilityManager *manager = [LWNetworkReachabilityManager sharedManager];

    if (manager.isReachableViaWiFi) {
        // WiFi: Load full articles with images
        [self loadArticlesWithFullContent:YES
                                   images:YES
                              imageQuality:ImageQualityHigh];
        NSLog(@"Loading full content with high-quality images");
    }
    else if (manager.isReachableViaWWAN) {
        // Cellular: Load text with compressed images
        [self loadArticlesWithFullContent:YES
                                   images:YES
                              imageQuality:ImageQualityCompressed];
        NSLog(@"Loading content with compressed images to save data");
    }
    else {
        // Offline: Load cached articles only
        [self loadCachedArticles];
        [self showBanner:@"You're offline. Showing cached articles."];
    }
}
```

---

## Best Practices

1. **Start Monitoring Early**: Begin monitoring in `application:didFinishLaunchingWithOptions:` or early in your app lifecycle to ensure accurate network status from the start

2. **Don't Prevent User Actions**: Network reachability should be used for informational purposes and optimization, not to prevent users from attempting network requests. The user might have connectivity that the reachability API doesn't detect.

3. **Handle All Network States**: Always handle all four possible states (Unknown, Not Reachable, WWAN, WiFi) in your callbacks to prevent unexpected behavior

4. **Optimize for Connection Type**:
   - **WiFi**: Enable HD media, automatic backups, and sync operations
   - **WWAN**: Use compressed content, warn before large downloads, defer non-critical operations
   - **Not Reachable**: Show cached content, save user data locally, queue operations for retry

5. **Use Weak References**: Always use weak self references in blocks to avoid retain cycles
   ```objective-c
   __weak typeof(self) weakSelf = self;
   [manager setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
       __strong typeof(weakSelf) strongSelf = weakSelf;
       // Use strongSelf here
   }];
   ```

6. **Respect User Preferences**: Consider user settings for cellular data usage. Some users may want to use cellular for all operations, while others want to conserve data.

7. **Stop When Not Needed**: Call `stopMonitoring` when you no longer need updates to conserve system resources

8. **Use for Retry Logic**: Use reachability to understand why a network operation failed or to trigger retry when connection is restored

9. **Monitor Connection Transitions**: Pay special attention to WiFi-to-WWAN transitions for apps with data-intensive operations

10. **Test All Scenarios**: Test your app's behavior on WiFi, 4G/5G, 3G, and offline modes to ensure proper handling of all connection types

---

## Important Notes

- **Start Monitoring First**: You must call `startMonitoring` before reachability status can be determined. The status remains `Unknown` until monitoring begins.

- **SystemConfiguration Framework**: The library uses Apple's SystemConfiguration framework for network monitoring. Ensure this framework is linked in your project.

- **Main Queue Callbacks**: All callbacks and notifications are automatically executed on the main queue, making it safe to update UI directly from the callback blocks.

- **Initial Status**: The initial status is set to `LWNetworkReachabilityStatusUnknown` (-1) until monitoring begins and the first status check completes.

- **WiFi vs WWAN Detection**: The library accurately detects the connection type:
  - **WiFi**: Returns `true` for `isReachableViaWiFi` when connected to any WiFi network (802.11 a/b/g/n/ac/ax)
  - **WWAN**: Returns `true` for `isReachableViaWWAN` for all cellular connections (2G/3G/4G/5G)
  - The library does not distinguish between specific cellular generations (3G vs 4G vs 5G)

- **Reachability vs Actual Connectivity**: Reachability indicates whether an interface route exists to the destination. It does not guarantee that data can actually be transmitted. Always handle network request failures gracefully.

- **VPN Connections**: When connected via VPN over WiFi, the status reports as WiFi. When connected via VPN over cellular, it reports as WWAN.

- **Airplane Mode**: When Airplane Mode is enabled, the status will be `NotReachable` even if WiFi is subsequently enabled.

- **Background Monitoring**: The library continues to monitor network status when your app is in the background, and callbacks will be queued until your app returns to the foreground.

---

## API Reference

### Class Methods

#### Singleton Instance
```objective-c
+ (instancetype)sharedManager;
```
Returns the global shared network reachability manager instance. Use this for app-wide network monitoring.

#### Create New Instance
```objective-c
+ (instancetype)manager;
```
Creates a new network reachability manager with the default socket address (0.0.0.0).

```objective-c
+ (instancetype)managerForDomain:(NSString *)domain;
```
Creates a manager for monitoring a specific domain (e.g., `@"www.apple.com"`).

```objective-c
+ (instancetype)managerForAddress:(const void *)address;
```
Creates a manager for monitoring a specific socket address (e.g., 8.8.8.8 for Google DNS).

### Instance Methods

#### Start/Stop Monitoring
```objective-c
- (void)startMonitoring;
```
Begins monitoring network reachability changes. Must be called before status can be determined.

```objective-c
- (void)stopMonitoring;
```
Stops monitoring network reachability changes. Call this to free resources when monitoring is no longer needed.

#### Set Callback
```objective-c
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(LWNetworkReachabilityStatus status))block;
```
Sets a block to be executed when network status changes. The block receives the new status as a parameter.

#### Get Status Description
```objective-c
- (NSString *)localizedNetworkReachabilityStatusString;
```
Returns a localized string description of the current network status.

### Properties

#### Current Status
```objective-c
@property (readonly, nonatomic, assign) LWNetworkReachabilityStatus networkReachabilityStatus;
```
The current network reachability status enum value.

#### Reachability Checks
```objective-c
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;
```
Returns `YES` if network is reachable via either WiFi or WWAN.

```objective-c
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
```
Returns `YES` if network is reachable via cellular connection (2G/3G/4G/5G).

```objective-c
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;
```
Returns `YES` if network is reachable via WiFi connection.

### Constants

#### Notification Names
```objective-c
FOUNDATION_EXPORT NSString * const LWNetworkingReachabilityDidChangeNotification;
```
Posted when network reachability status changes.

```objective-c
FOUNDATION_EXPORT NSString * const LWNetworkingReachabilityNotificationStatusItem;
```
Key for accessing the status value in the notification's userInfo dictionary.

#### Functions
```objective-c
FOUNDATION_EXPORT NSString * LWStringFromNetworkReachabilityStatus(LWNetworkReachabilityStatus status);
```
Converts a status enum value to a localized string representation.

---

## Example Project

To run the example project:

1. Clone the repository
2. Navigate to the Example directory
3. Run `pod install`
4. Open `LWReachabilityManager.xcworkspace`

Example code:

```Objective-C
// Monitor network status
__weak typeof(self) weakSelf = self;
[[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    weakSelf.networkReachabilityStatus = status;
}];
[[LWNetworkReachabilityManager sharedManager] startMonitoring];

// Check if reachable
BOOL isReachable = [[LWNetworkReachabilityManager sharedManager] isReachable];
```

---

## Author

**luowei**
Email: luowei@wodedata.com

---

## License

LWReachabilityManager is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

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

---

## Additional Resources

- [Apple Reachability Sample Code](https://developer.apple.com/library/ios/samplecode/reachability/)
- [SystemConfiguration Framework Documentation](https://developer.apple.com/documentation/systemconfiguration)
- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - Reference implementation
