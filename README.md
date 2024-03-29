# LWReachabilityManager

[![CI Status](https://img.shields.io/travis/luowei/LWReachabilityManager.svg?style=flat)](https://travis-ci.org/luowei/LWReachabilityManager)
[![Version](https://img.shields.io/cocoapods/v/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)
[![License](https://img.shields.io/cocoapods/l/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)
[![Platform](https://img.shields.io/cocoapods/p/LWReachabilityManager.svg?style=flat)](https://cocoapods.org/pods/LWReachabilityManager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```Objective-C
//monitor network status
__weak typeof(self) weakSelf = self;
[[LWNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LWNetworkReachabilityStatus status) {
    weakSelf.networkReachabilityStatus = status;
}];
[[LWNetworkReachabilityManager sharedManager] startMonitoring];


BOOL isReachable = [[LWNetworkReachabilityManager sharedManager] isReachable];
```

## Requirements

## Installation

LWReachabilityManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWReachabilityManager'
```

**Carthage**
```ruby
github "luowei/LWReachabilityManager"
```

## Author

luowei, luowei@wodedata.com

## License

LWReachabilityManager is available under the MIT license. See the LICENSE file for more info.
