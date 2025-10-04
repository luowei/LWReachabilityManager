#
# Be sure to run `pod lib lint LWReachabilityManager_swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWReachabilityManager_swift'
  s.version          = '1.0.0'
  s.summary          = 'LWReachabilityManager Swift版本，ReachabilityManager山寨版.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LWReachabilityManager Swift版本，ReachabilityManager山寨版.
                       DESC

  s.homepage         = 'https://github.com/luowei/LWReachabilityManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWReachabilityManager.git'}
  # s.source           = { :git => 'https://gitlab.com/ioslibraries1/lwreachabilitymanager.git'}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'LWReachabilityManager_swift/Classes/**/*'

  # s.resource_bundles = {
  #   'LWReachabilityManager_swift' => ['LWReachabilityManager_swift/Assets/*.png']
  # }

  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
