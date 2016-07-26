//
//  LocationManagerStub.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/24.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation
import CoreLocation
@testable
import RxLocationManager

class LocationManagerStub: CLLocationManagerBridge{
    var whenInUseAuthorizationRequested = false
    var alwaysAuthorizationRequested = false
    
    var currentLocation:CLLocation?
    var currentDistanceFilter: CLLocationDistance = 0.0
    var currentDesiredAccuracy: CLLocationAccuracy = 0.0
    var currentPausesLocationUpdatesAutomatically = false
    var currentAllowsBackgroundLocationUpdates = false
    var currentActivityType = CLActivityType.Other
    
    var currentlyDeferedSetting:(CLLocationDistance, NSTimeInterval)?
    
    var currentHeadingFilter = 0.0
    var currentHeadingOrientation = CLDeviceOrientation.Portrait
    
    var currentMonitoredRegions = Set<CLRegion>()
    var currentRegionStateRequests = Set<CLRegion>()
    var currangRangedBeaconRegions = Set<CLBeaconRegion>()
    
    var updatingLocation = false
    var locationRequested = false
    var updatingHeading = false
    var monitoringSignificantLocationChange = false
    
    //instance methods on CLLocationManager instance
    #if os(iOS) || os(watchOS) || os(tvOS)
    override func requestWhenInUseAuthorization(){
        whenInUseAuthorizationRequested = true
    }
    #endif
    #if os(iOS) || os(watchOS)
    override func requestAlwaysAuthorization(){
        alwaysAuthorizationRequested = true
    }
    #endif
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    override var location: CLLocation? {
        get{
            return currentLocation
        }
    }
    #endif
    
    override func startUpdatingLocation(){
        updatingLocation = true
    }
    override func stopUpdatingLocation(){
        updatingLocation = false
    }
    @available(iOS 9.0, *)
    override func requestLocation(){
        locationRequested = true
    }
    override var distanceFilter: CLLocationDistance {
        get{
            return currentDistanceFilter
        }
        set{
            currentDistanceFilter = newValue
        }
    }
    override var desiredAccuracy: CLLocationAccuracy {
        get{
            return currentDesiredAccuracy
        }
        set{
            currentDesiredAccuracy = newValue
        }
    }
    #if os(iOS)
    override var pausesLocationUpdatesAutomatically: Bool {
        get{
           return currentPausesLocationUpdatesAutomatically
        }
        set{
            currentPausesLocationUpdatesAutomatically = newValue
        }
    }
    @available(iOS 9.0, *)
    override var allowsBackgroundLocationUpdates: Bool {
        get{
            return currentAllowsBackgroundLocationUpdates
        }
        set{
            return currentAllowsBackgroundLocationUpdates = newValue
        }
    }
    override func allowDeferredLocationUpdatesUntilTraveled(distance: CLLocationDistance, timeout: NSTimeInterval){
        currentlyDeferedSetting = (distance, timeout)
    }
    override func disallowDeferredLocationUpdates(){
        currentlyDeferedSetting = nil
    }
    override var activityType: CLActivityType {
        get{
            return currentActivityType
        }
        set{
            currentActivityType = newValue
        }
    }
    #endif
    
    #if os(iOS) || os(OSX)
    override func startMonitoringSignificantLocationChanges(){
        monitoringSignificantLocationChange = true
    }
    override func stopMonitoringSignificantLocationChanges(){
        monitoringSignificantLocationChange = false
    }
    #endif
    
    #if os(iOS)
    override func startUpdatingHeading(){
        updatingHeading = true
    }
    override func stopUpdatingHeading(){
        updatingHeading = false
    }
    override func dismissHeadingCalibrationDisplay(){
        
    }
    override var headingFilter: CLLocationDegrees {
        get{
            return currentHeadingFilter
        }
        set{
            currentHeadingFilter = newValue
        }
    }
    override var headingOrientation: CLDeviceOrientation {
        get{
            return currentHeadingOrientation
        }
        set{
            currentHeadingOrientation = newValue
        }
    }
    #endif
    
    #if os(iOS) || os(OSX)
    override func startMonitoringForRegion(region: CLRegion){
        currentMonitoredRegions.insert(region)
    }
    override func stopMonitoringForRegion(region: CLRegion){
        currentMonitoredRegions.remove(region)
    }
    override var monitoredRegions: Set<CLRegion> {
        get{
            return currentMonitoredRegions
        }
    }
    override var maximumRegionMonitoringDistance: CLLocationDistance {
        get{
            return 200
        }
    }
    override func requestStateForRegion(region: CLRegion){
        currentRegionStateRequests.insert(region)
    }
    #endif
    
    #if os(iOS)
    override var rangedRegions: Set<CLRegion> {
        get{
            return currangRangedBeaconRegions
        }
    }
    override func startRangingBeaconsInRegion(region: CLBeaconRegion){
        currangRangedBeaconRegions.insert(region)
    }
    override func stopRangingBeaconsInRegion(region: CLBeaconRegion){
        currangRangedBeaconRegions.remove(region)
    }
    #endif
    
    #if os(iOS)
    override func startMonitoringVisits(){
        
    }
    override func stopMonitoringVisits(){
        
    }
    #endif
    
    required init(){
        super.init()
    }
    
}

