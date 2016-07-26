RxLocationManager: Reactive version of CLLocationManager in iOS/macOS/watchOS/tvOS


## Introduction
You may find CLLocationManager awkward to use if you adopt FRP(RxSwift) paradigm to develop apps. RxLocationManager is an attempt to simplify all of these into consistent reactive-styled APIs, so that you don't need to worry about things like create delegate, and save CLLocationManager instance somewhere(e.g. AppDelegate) for sharing globally, etc. Everything is behind RxLocationManager class and its static methods and variables. Internally RxLocationManager has multiple sharing CLLocationManager+Delegate instances, and manage them efficiently. Instead of providing an "all-in-one" class like CLLocationManager does, RxLocationManager divides properties/methods into several groups based on their relativity, for example, location related APIs go into *StandardLocationService* class, heading update related APIs go into *HeadingUpdateService* class, region monitoring related APIs go into *RegionMonitoringService* class, so it's more clear to use.

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