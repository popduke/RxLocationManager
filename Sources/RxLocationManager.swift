//
//  RxLocationManager.swift
//  PaperChat
//
//  Created by Yonny Hao on 16/6/14.
//  Copyright © 2016年 HaoYu. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

//MARK: RxLocationManager
public class RxLocationManager{
    private static var defaultLocationMgr: LocationManagerBridge = {
        let locMgr = Bridge()
        locMgr.didChangeAuthorizationStatus = {
            clLocMgr, status in
            authorizationStatusSink.onNext(status)
            enabledSink.onNext(Bridge.locationServicesEnabled())
        }
        return locMgr
    }()
    
    private static var enabledSink:ReplaySubject<Bool> = {
        let replaySubject:ReplaySubject<Bool> = ReplaySubject.create(bufferSize: 1)
        replaySubject.onNext(Bridge.locationServicesEnabled())
        //Force initialize defaultLocationMgr, since it's always lazy
        defaultLocationMgr = defaultLocationMgr
        return replaySubject
    }()
    
    /// Observable of location service enabled status change, start with current authorization status
    public static var enabled:Observable<Bool>{
        get{
            return enabledSink.distinctUntilChanged()
        }
    }
    
    private static var authorizationStatusSink:ReplaySubject<CLAuthorizationStatus> = {
        let replaySubject:ReplaySubject<CLAuthorizationStatus> = ReplaySubject.create(bufferSize: 1)
        replaySubject.onNext(Bridge.authorizationStatus())
        //Force initialize defaultLocationMgr, since it's always lazy
        defaultLocationMgr = defaultLocationMgr
        return replaySubject
    }()
    
    /// Observable of the app's authorization status change, start with current authorization status
    public static var authorizationStatus: Observable<CLAuthorizationStatus>{
        get{
            return authorizationStatusSink.distinctUntilChanged()
        }
    }
    
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    /**
     Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/requestWhenInUseAuthorization)
     */
    public static func requestWhenInUseAuthorization(){
        defaultLocationMgr.requestWhenInUseAuthorization()
    }
    #endif
    
    #if os(iOS) || os(watchOS)
    /**
     Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/requestAlwaysAuthorization)
     */
    public static func requestAlwaysAuthorization(){
        defaultLocationMgr.requestAlwaysAuthorization()
    }
    #endif
    
    #if os(iOS) || os(OSX)
    /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/significantLocationChangeMonitoringAvailable)
    public static let significantLocationChangeMonitoringAvailable = Bridge.significantLocationChangeMonitoringAvailable()
    
    /**
     Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/isMonitoringAvailableForClass:)
     
     - parameter regionClass: to test
     
     - returns: self for chaining call
     */
    public static func isMonitoringAvailableForClass(regionClass: AnyClass) -> Bool{
        return Bridge.isMonitoringAvailableForClass(regionClass)
    }
    #endif
    
    #if os(iOS)
    /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/deferredLocationUpdatesAvailable)
    public static let deferredLocationUpdatesAvailable = Bridge.deferredLocationUpdatesAvailable()

    /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/headingAvailable)
    public static let headingAvailable = Bridge.headingAvailable()
    
    /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/isRangingAvailable)
    public static let isRangingAvailable = Bridge.isRangingAvailable()
    #endif
    
    /// Shared standard location service
    public static let Standard: StandardLocationService = DefaultStandardLocationService(bridgeClass: Bridge.self)
    
    #if os(iOS) || os(OSX)
    /// Shared significant location update service
    public static let SignificantLocation: SignificantLocationUpdateService = DefaultSignificantLocationUpdateService(bridgeClass: Bridge.self)
    
    /// Shared region monitoring service
    public static let RegionMonitoring: RegionMonitoringService = DefaultRegionMonitoringService(bridgeClass: Bridge.self)
    #endif
    
    #if os(iOS)
    /// Shared visit monitoring service
    public static let VisitMonitoring: MonitoringVisitsService = DefaultMonitoringVisitsService(bridgeClass: Bridge.self)
    /// Shared beacon ranging service
    public static let BeaconRanging: BeaconRangingService = DefaultBeaconRangingService(bridgeClass: Bridge.self)
    /// Shared heading update service
    public static let HeadingUpdate: HeadingUpdateService = DefaultHeadingUpdateService(bridgeClass: Bridge.self)
    #endif
}

