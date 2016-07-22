//
//  RxLocationManager.swift
//  PaperChat
//
//  Created by HaoYu on 16/6/14.
//  Copyright © 2016年 HaoYu. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

//MARK: RxLocationManager
public class RxLocationManager{
    private static var defaultLocationMgr: Bridge = {
        let locMgr = Bridge()
        locMgr.didChangeAuthorizationStatus = {
            clLocMgr, status in
            authorizationStatusSink.onNext(status)
            enabledSink.onNext(CLLocationManager.locationServicesEnabled())
        }
        return locMgr
    }()
    
    private static var enabledSink:ReplaySubject<Bool> = {
        let replaySubject:ReplaySubject<Bool> = ReplaySubject.create(bufferSize: 1)
        replaySubject.onNext(CLLocationManager.locationServicesEnabled())
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
        replaySubject.onNext(CLLocationManager.authorizationStatus())
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
     same as the one in CLLocationManager
     */
    public static func requestWhenInUseAuthorization(){
        defaultLocationMgr.manager.requestWhenInUseAuthorization()
    }
    #endif
    
    #if os(iOS) || os(watchOS)
    /**
     same as the one in CLLocationManager
     */
    public static func requestAlwaysAuthorization(){
        defaultLocationMgr.manager.requestAlwaysAuthorization()
    }
    #endif
    
    #if os(iOS) || os(OSX)
    /// same in CLLocationManager
    public static let significantLocationChangeMonitoringAvailable = CLLocationManager.significantLocationChangeMonitoringAvailable()
    
    public static func isMonitoringAvailableForClass(regionClass: AnyClass) -> Bool{
        return CLLocationManager.isMonitoringAvailableForClass(regionClass)
    }
    #endif
    
    #if os(iOS)
    /// same in CLLocationManager
    public static let deferredLocationUpdatesAvailable = CLLocationManager.deferredLocationUpdatesAvailable()

    /// same in CLLocationManager
    public static let headingAvailable = CLLocationManager.headingAvailable()
    
    /// same in CLLocationManager
    public static let isRangingAvailable = CLLocationManager.isRangingAvailable()
    #endif
    
    /// shared standard location service
    public static let Standard: StandardLocationService = DefaultStandardLocationService()
    
    #if os(iOS) || os(OSX)
    /// shared significant location update service
    public static let SignificantLocation: SignificantLocationUpdateService = DefaultSignificantLocationUpdateService()
    
    /// shared region monitoring service
    public static let RegionMonitoring: RegionMonitoringService = DefaultRegionMonitoringService()
    #endif
    
    #if os(iOS)
    /// shared visit monitoring service
    public static let VisitMonitoring: MonitoringVisitsService = DefaultMonitoringVisitsService()
    
    /// shared heading update service
    public static let HeadingUpdate: HeadingUpdateService = DefaultHeadingUpdateService()
    #endif
}

