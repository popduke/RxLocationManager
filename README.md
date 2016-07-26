RxLocationManager: Reactive version of CLLocationManager in iOS/macOS/watchOS/tvOS


## Introduction
You may find CLLocationManager awkward to use if you adopt FRP(RxSwift) paradigm to develop apps. RxLocationManager is an attempt to simplify all of these into consistent reactive-styled APIs, so that you don't need to worry about things like create delegate, and save CLLocationManager instance somewhere(e.g. AppDelegate) for sharing globally, etc. Everything is behind RxLocationManager class and its static methods and variables. Internally RxLocationManager has multiple sharing CLLocationManager+Delegate instances, and manage them efficiently in terms of memory usage and battery life. Instead of providing an "all-in-one" class like CLLocationManager does, RxLocationManager divides properties/methods into several groups based on their relativity, for example, location related APIs go into *StandardLocationService* class, heading update related APIs go into *HeadingUpdateService* class, region monitoring related APIs go into *RegionMonitoringService* class, so it's more clear to use.

## Installation
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)
Choose subspec based on your app's target platform, and replace 'YOUR\_TARGET\_NAME'

```
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'RxLocationManager/iOS',    '~> 1.0'
#   pod 'RxLocationManager/macOS',  '~> 1.0'
#   pod 'RxLocationManager/watchOS','~> 1.0'
#   pod 'RxLocationManager/tvOS',   '~> 1.0'
end

```

### [Carthage](https://github.com/Carthage/Carthage)
Add following line to `Cartfile`

```
github "popduke/RxLocationManager" ~> 1.0
```
and run

```
$ carthage update
```
### [Git submodules](https://git-scm.com/docs/git-submodule)
* Run following line to add RxLocationManager as a submodule

```
$ git submodule add git@github.com:popduke/RxLocationManager.git
```

* Drag `RxLocationManager.xcodeproj` into Project Navigator
* Go to `Project > Targets > Build Phases > Link Binary With Libraries`, click `+` and select `RxLocationManager [Platform]` targets

## Usage
Add below line to import RxLocationManager module
```
import RxLocationManager
```

### Listen to Location Service's enable/disable status change

```
RxLocationManager.enable
.map{
   //$0 is Boolean
   return $0 ? "enabled" : "disabled"
}
.subscribeNext{
   print("Location Service is \($0)")
}
.addDisposableTo(disposeBag)
```

### Listen to app's authorization status change

```
RxLocationManager.authorizationStatus
.subscribeNext{
   //$0 is CLAuthorizationStatus
   print("Current authorization status is \($0)")
}
.addDisposableTo(disposeBag)
```

### Request authorization to your app
```
//ask for WhenInUse authorization
RxLocationManager.requestWhenInUseAuthorization()
//ask for Always authorization
RxLocationManager.requestAlwaysAuthorization()
```

### Determine service availability
```
#if os(iOS) || os(OSX)
RxLocationManager.significantLocationChangeMonitoringAvailable
RxLocationManager.isMonitoringAvailableForClass(regionClass: AnyClass) -> Bool
#endif

#if os(iOS)
RxLocationManager.deferredLocationUpdatesAvailable 
RxLocationManager.headingAvailable 
RxLocationManager.isRangingAvailable
#endif
```

### Standard Location Service
*StandardLocationService* contains two main *Observable*s: *Located* and *Locating*, *Located* reports only one *CLLocation* object per subscription and complete, representing the current determined location of device; *Locating* reports series of *CLLocation* objects upon observing, representing the changing location of device. Multiple subscriptions share a single underlying CLLocationManager object, RxLocationManager starts location updating when first subscription is made and stops it after last subscription is disposed.
#### Determine current location of device

```
// RxLocationManager.Standard is a shared standard location service instance
#if os(iOS) || os(watchOS) || os(tvOS)
RxLocationManager.Standard.located.subscribe{
    event in
    switch event{
    case .Next(let location):
        // the event will only be triggered once to report current determined location of device
        print("Current Location is \(location)")
    case .Completed:
        // completed event will get triggered after location is reported successfully
        print("Subscription is Completed")
    case .Error(let error):
        // in case some error occurred during determining device location, e.g. LocationUnknown
    }
}
#endif
```

```
#if os(iOS) || os(OSX)
RxLocationManager.Standard.locating.subscribe{
    event in
    switch event{
    case .Next(let location):
        // series events will be delivered during subscription
        print("Current Location is \(location)")
    case .Completed:
        // No complete event will be generated
    case .Error(let error):
        // LocationUnknown error will be ignored, and other errors reported
    }
}
#endif
```