# DietLens
> use food recognition and food text search technology to record a nutri-based foodDiary.

[![Swift Version][swift-image]][swift-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EZSwiftExtensions.svg)](https://img.shields.io/cocoapods/v/LFAlertController.svg)
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)

## Features & Project Structure
- Service: 
- APIService: 
- **Alamofire**: communicate with backend writing down here.
- **QiniuUpload**: QiniuConfig used here for image uploading.
- LRU cache: text search **Recent Tab** recent history functionality,currently use TextSuggestionCacheLRU only.
- DataManager: all the **Data parsing** logic writing down here.
- CountDownTimer: service for **SMS timer count down**.
- CustomPhotoAlbum: save images to **Album** after photo taking.
- View:
- CustomizedView: **customized UI component** used here.
- TableHeader:put all the customized **tableview header** logic code & xib here.
- TableCell:put all the customized tableCell logic code here.
- Controller: all the view controller( View logic ) writing down here.
- Model: all the POJO structue define here.

## Requirements

- iOS 10.0+
- Xcode 9.3

## Reference Library 

- [Alamofire](https://github.com/Alamofire/Alamofire): Http Request framework.
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON): JSON parsing lib.
- [FSCalendar](https://github.com/WenchaoD/FSCalendar): Calendar lib used in the foodDiary page.
- [XLPagerTabStrip](https://github.com/xmartlabs/XLPagerTabStrip): Android PagerTabStrip for iOS used in the camera/text page.
- [Firebase](https://firebase.google.com): Notification & Analytic lib.
- [Crashlytics](https://fabric.io): App crashing monitoring lib.
- [Kingfisher](https://github.com/onevcat/Kingfisher): Image loader & caching.
- [FacebookLogin](https://developers.facebook.com/docs/facebook-login/) & [GoogleSignIn](https://developers.google.com/identity/sign-in/ios/): Third party login lib.
- [ReachabilitySwift](https://github.com/ashleymills/Reachability.swift): Networking status monitoring lib.
- [BAFluidView](https://github.com/antiguab/BAFluidView): Home page fluid animiation view lib.

## Installation
run
```
pod install
```
at project root directory


#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `YourLibrary` by adding it to your `Podfile`:

```ruby
platform :ios, '10.0'
use_frameworks!
pod 'YourLibrary'
```

To get the full benefits import `YourLibrary` wherever you import UIKit

``` swift
import UIKit
import YourLibrary
```

## Usage example

```swift
import EZSwiftExtensions
ez.detectScreenShot { () -> () in
print("User took a screen shot")
}
```


[swift-image]:https://img.shields.io/badge/swift-4.0-orange.svg
[swift-url]: https://swift.org/
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
