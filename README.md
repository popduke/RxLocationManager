A Reactive LocationManager in Swift

[![CocoaPods Compatible](https://img.shields.io/badge/cocoapod-v1.0-brightgreen.svg)](https://cocoapods.org)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/Platform-%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg)](https://github.com/popduke/RxLocationManager)

## Introduction
You may find CLLocationManager awkward to use if you adopt [FRP](http://reactivex.io/)([RxSwift](https://github.com/ReactiveX/RxSwift)) paradigm to develop apps. RxLocationManager is an attempt to create a "reactive" skin around CLLocationManager, so that you don't need to worry about things like conform your view controller to CLLocationManagerDelegate which sometimes feels unnatural, where to put CLLocationManager instance(e.g. AppDelegate) for easily referencing, etc. Everything is behind RxLocationManager class and its static methods and variables. Internally RxLocationManager has multiple sharing CLLocationManager+Delegate instances, and manage them efficiently in terms of memory usage and battery life. Instead of providing an "all-in-one" class like CLLocationManager does, RxLocationManager divides properties/methods into several groups based on their relativity, for example, location related APIs go into *StandardLocationService* class, heading update related APIs go into *HeadingUpdateService* class, region monitoring related APIs go into *RegionMonitoringService* class which also includes ranging beacons capability, and visits monitoring related APIs go into *MonitoringVisitsService*, so it's more clear to use.

## Installation
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)
Add RxLocationManager dependency to your Podfile
```
# Podfile
use_frameworks!

# replace YOUR_TARGET_NAME with yours
target 'YOUR_TARGET_NAME' do
    pod 'RxLocationManager',    '~> 1.0'
end
```
and run 
```
$ pod install
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
**:pushpin: Always consult official document of [*CLLocationManager*](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html#//apple_ref/occ/cl/CLLocationManager) to learn how to configure it to work in different modes :pushpin:**

Add below line to import RxLocationManager module
```
import RxLocationManager
```

### Observe Location Service's enable/disable status change

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

### Observe app's authorization status change

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
.addDisposableTo(disposeBag)
#endif
```

#### Monitoring location update of device
```
#if os(iOS) || os(OSX)
RxLocationManager.Standard.locating.subscribe{
    event in
    switch event{
    case .Next(let location):
        // series of events will be delivered during subscription
        print("Current Location is \(location)")
    case .Completed:
        // no complete event
    case .Error(let error):
        // LocationUnknown error will be ignored, and other errors reported
    }
}
.addDisposableTo(disposeBag)
#endif
```
#### Configuration
Before start subscribing to *located* or *locating*, you can also configure the standard location service instance through below chaining style APIs
```
RxLocationManager.Standard.distanceFilter(distance: CLLocationDistance) -> StandardLocationService
RxLocationManager.Standard.desiredAccuracy(desiredAccuracy: CLLocationAccuracy) -> StandardLocationService

#if os(iOS)
RxLocationManager.Standard.allowsBackgroundLocationUpdates(allow : Bool) -> StandardLocationService
RxLocationManager.Standard.activityType(type: CLActivityType) -> StandardLocationService
#endif
```

#### Enable auto-paused mode for location delivery, and observe the notification of pausing state change
```
#if os(iOS)
RxLocationManager.Standard.pausesLocationUpdatesAutomatically(true)

RxLocationManager.Standard.isPaused
.map{
    //$0 is Boolean
    return $0 ? "Paused" : "Resumed"
}
.subscribeNext{
   print("Location Updating is \($0)")
}
.addDisposableTo(disposeBag)
#endif
```

#### Setup/remove deferred location update condition and observe when condition is satisfied or finished with error
```
#if os(iOS)
//Setup deferred location update condition
RxLocationManager.Standard.allowDeferredLocationUpdates(untilTraveled:100, timeout: 120)

//Remove current deferred update condition
RxLocationManager.Standard.disallowDeferredLocationUpdates()

//Observe the event when condition is satisfied or finished with error
RxLocationManager.Standard.deferredUpdateFinished
.map{
    //$0 is NSError?
    return $0 == nil ? "Finished" : "Finished with error code \($0.code) in \($0.domain)"
}
.subscribeNext{
    error in
    print("Location Updating is \($0)")
}
.addDisposableTo(disposeBag)
#endif
```

#### Multiple standard location services
In some cases you need more than one standard location service in your app, which configured differently, you can create a new one by cloning from the shared
```
var anotherStandardLocationService = RxLocationManager.Standard.clone()
anotherStandardLocationService.distanceFilter(100).desiredAccuracy(50)
```

### Significant Location Update Service

*SignificantLocationUpdateService* contains only one *Observable*: *locating*, which reports series of *CLLocation* objects upon observing, representing the significant location change of device. Multiple subscriptions share a single underlying CLLocationManager object, RxLocationManager starts monitoring significant location change when first subscription is made and stops it after last subscription is disposed.
```
#if os(iOS) || os(OSX)
// RxLocationManager.SignificantLocation is the shared significant location update service instance
RxLocationManager.SignificantLocation.locating.subscribe{
    event in
    switch event{
    case .Next(let location):
        // series of events will be delivered during subscription
        print("Current Location is \(location)")
    case .Completed:
        // no complete event
    case .Error(let error):
        // in case errors
    }
}
.addDisposableTo(disposeBag)
#endif
```

### Heading Update Service

*HeadingUpdateService* contains only one *Observable*: *heading*, which reports series of *CLHeading* objects upon observing, representing heading change of device. Multiple subscriptions share a single underlying CLLocationManager object, RxLocationManager starts monitoring device heading change when first subscription is made and stops it after last subscription is disposed.

#### Observe heading change of device
```
#if os(iOS)
// RxLocationManager.HeadingUpdate is the shared heading update service instance
RxLocationManager.HeadingUpdate.heading.subscribeNext{
    event in
    switch event{
    case .Next(let heading):
        // series of events will be delivered during subscription
        print("Current heading is \(heading)")
    case .Completed:
        // no complete event
    case .Error(let error):
        // in case errors
    }
}
.addDisposableTo(disposeBag)
#endif
```

#### Configuration
Before start subscribing to *heading*, you can also configure the heading update service instance through below chaining style APIs
```
#if os(iOS)
RxLocationManager.HeadingUpdate.headingFilter(degrees:CLLocationDegrees) -> HeadingUpdateService
RxLocationManager.HeadingUpdate.headingOrientation(degrees:CLDeviceOrientation) -> HeadingUpdateService
RxLocationManager.HeadingUpdate.displayHeadingCalibration(should:Bool) -> HeadingUpdateService

//Use following to methods to start/stop location updating, so that true heading value will be reported
RxLocationManager.HeadingUpdate.startTrueHeading(withParams:(distanceFilter:CLLocationDistance, desiredAccuracy:CLLocationAccuracy))
RxLocationManager.HeadingUpdate.stopTrueHeading()
#endif
```

#### Dismiss heading calibration display if any
```
#if os(iOS)
RxLocationManager.HeadingUpdate.dismissHeadingCalibrationDisplay() 
#endif
```

#### Multiple heading update services
In some cases you need more than one heading update service in your app, which configured differently, you can create a new one by cloning from the shared
```
var anotherHeadingUpdateService = RxLocationManager.HeadingUpdate.clone()
anotherHeadingUpdateService.distanceFilter(100).desiredAccuracy(50)
```
### Region Monitoring Service

#### Observe the changes to the collection of current monitored regions 
```
#if os(iOS) || os(OSX)
// methods to start|stop monitoring regions
RxLocationManager.RegionMonitoring.startMonitoringForRegions(regions: [CLRegion]) -> RegionMonitoringService
RxLocationManager.RegionMonitoring.stopMonitoringForRegions(regions: [CLRegion]) -> RegionMonitoringService
RxLocationManager.RegionMonitoring.stopMonitoringForAllRegions() -> RegionMonitoringService

RxLocationManager.RegionMonitoring.monitoredRegions.subscribeNext{
    //happens no matter when new region is added or existing one gets removed from the monitored regions set
    regions in
    print("Current monitoring \(regions.count) regions")
}
.addDisposableTo(disposeBag)
#endif
```

#### Observe region enter/exit event
```
#if os(iOS) || os(OSX)
RxLocationManager.RegionMonitoring.entering.subscribeNext{
    region in
    print("Device is entering the region: \(region.identifier)")
}
.addDisposableTo(disposeBag)

RxLocationManager.RegionMonitoring.exiting.subscribeNext{
    region in
    print("Device is leaving the region: \(region.identifier)")
}
.addDisposableTo(disposeBag)
#endif
```

#### Ask for the current state of monitored regions
```
RxLocationManager.RegionMonitoring.requestRegionsState(regions:[CLRegion]) -> RegionMonitoringService
RxLocationManager.RegionMonitoring.determinedRegionState.subscribeNext{
    region, state in
    print("the region: \(region.identifier) is in state: \(state.rawValue)")
}
.addDisposableTo(disposeBag)
```

#### Start/stop ranging beacons in range
```
#if os(iOS)
RxLocationManager.RegionMonitoring.startRangingBeaconsInRegion(region: CLBeaconRegion)
RxLocationManager.RegionMonitoring.stopRangingBeaconsInRegion(region: CLBeaconRegion)
#endif
```

#### Observe ranged beacons
```
#if os(iOS)
RxLocationManager.RegionMonitoring.ranging.subscribeNext{
    beacons, inRegion in
    print("\(beacons.count) beacons ranged in range:\(inRange.identifier)")
}
.addDisposableTo(disposeBag)
#endif
```

### Monitoring Visits Service

#### Start/stop monitoring visits
```
#if os(iOS)
RxLocationManager.VisitMonitoring.startMonitoringVisits()
RxLocationManager.VisitMonitoring.stopMonitoringVisits()
#endif
```

#### Observe visit events
```
#if os(iOS)
RxLocationManager.VisitMonitoring.visiting.subscribeNext{
    visit in
    print("coordinate: \(visit.coordinate.longitude),\(visit.coordinate.latitude)")
}
.addDisposableTo(disposeBag)
#endif
```

## MIT License
