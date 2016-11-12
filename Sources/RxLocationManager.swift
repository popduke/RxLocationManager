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
open class RxLocationManager{
    fileprivate static var defaultLocationMgr: CLLocationManagerBridge = {
        let locMgr = CLLocationManagerBridge()
        locMgr.didChangeAuthorizationStatus = {
            clLocMgr, status in
            authorizationStatusSink.onNext(status)
            enabledSink.onNext(CLLocationManagerBridge.locationServicesEnabled())
        }
        return locMgr
    }()
    
    fileprivate static var enabledSink:ReplaySubject<Bool> = {
        let replaySubject:ReplaySubject<Bool> = ReplaySubject.create(bufferSize: 1)
        replaySubject.onNext(CLLocationManagerBridge.locationServicesEnabled())
        //Force initialize defaultLocationMgr, since it's always lazy
        defaultLocationMgr = defaultLocationMgr
        return replaySubject
    }()
    
    /// Observable of location service enabled status change, start with current authorization status
    open static var enabled:Observable<Bool>{
        get{
            return enabledSink.distinctUntilChanged()
        }
    }
    
    fileprivate static var authorizationStatusSink:ReplaySubject<CLAuthorizationStatus> = {
        let replaySubject:ReplaySubject<CLAuthorizationStatus> = ReplaySubject.create(bufferSize: 1)
        replaySubject.onNext(CLLocationManagerBridge.authorizationStatus())
        //Force initialize defaultLocationMgr, since it's always lazy
        defaultLocationMgr = defaultLocationMgr
        return replaySubject
    }()
    
    /// Observable of the app's authorization status change, start with current authorization status
    open static var authorizationStatus: Observable<CLAuthorizationStatus>{
        get{
            return authorizationStatusSink.distinctUntilChanged()
        }
    }
    
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    /**
     Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/requestWhenInUseAuthorization)
     */
    open static func requestWhenInUseAuthorization(){
        defaultLocationMgr.requestWhenInUseAuthorization()
    }
    #endif
    
    #if os(iOS) || os(watchOS)
    /**
     Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/requestAlwaysAuthorization)
     */
    open static func requestAlwaysAuthorization(){
        defaultLocationMgr.requestAlwaysAuthorization()
    }
    #endif
    
    #if os(iOS) || os(OSX)
    /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/significantLocationChangeMonitoringAvailable)
    open static var significantLocationChangeMonitoringAvailable:Bool {
        get{
            return CLLocationManagerBridge.significantLocationChangeMonitoringAvailable()
        }
    }
    
    /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/headingAvailable)
    open static var headingAvailable:Bool{
        return CLLocationManagerBridge.headingAvailable()
    }
    
    /**
     Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/isMonitoringAvailableForClass:)
     
     - parameter regionClass: to test
     
     - returns: self for chaining call
     */
    open static func isMonitoringAvailableForClass(regionClass: AnyClass) -> Bool{
        return CLLocationManagerBridge.isMonitoringAvailable(for: regionClass)
    }
    #endif
    
    #if os(iOS)
    /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/deferredLocationUpdatesAvailable)
    open static var deferredLocationUpdatesAvailable:Bool{
        get{
            return CLLocationManagerBridge.deferredLocationUpdatesAvailable()
        }
    }
    
    /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/clm/CLLocationManager/isRangingAvailable)
    open static var isRangingAvailable:Bool{
        get{
            return CLLocationManagerBridge.isRangingAvailable()
        }
    }
    #endif
    
    /// Shared standard location service
    open static let Standard: StandardLocationService = DefaultStandardLocationService(bridgeClass: CLLocationManagerBridge.self)
    
    #if os(iOS) || os(OSX)
    /// Shared significant location update service
    open static let SignificantLocation: SignificantLocationUpdateService = DefaultSignificantLocationUpdateService(bridgeClass: CLLocationManagerBridge.self)
    
    /// Shared region monitoring service
    open static let RegionMonitoring: RegionMonitoringService = DefaultRegionMonitoringService(bridgeClass: CLLocationManagerBridge.self)
    #endif
    
    #if os(iOS)
    /// Shared visit monitoring service
    open static let VisitMonitoring: MonitoringVisitsService = DefaultMonitoringVisitsService(bridgeClass: CLLocationManagerBridge.self)
    /// Shared heading update service
    open static let HeadingUpdate: HeadingUpdateService = DefaultHeadingUpdateService(bridgeClass: CLLocationManagerBridge.self)
    #endif
}

