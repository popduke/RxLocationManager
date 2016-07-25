//
//  Bridge.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerBridge{
    //class methods on CLLocationManager type
    static func authorizationStatus() -> CLAuthorizationStatus
    static func locationServicesEnabled() -> Bool

    #if os(iOS) || os(OSX)
    static func significantLocationChangeMonitoringAvailable() -> Bool
    static func isMonitoringAvailableForClass(regionClass: AnyClass) -> Bool
    #endif
    
    #if os(iOS)
    static func deferredLocationUpdatesAvailable() -> Bool
    static func headingAvailable() -> Bool
    static func isRangingAvailable() -> Bool
    #endif
    
    init()
    
    //instance methods on CLLocationManager instance
    #if os(iOS) || os(watchOS) || os(tvOS)
    func requestWhenInUseAuthorization()
    #endif
    #if os(iOS) || os(watchOS)
    func requestAlwaysAuthorization()
    #endif
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    var location: CLLocation? { get }
    #endif
    
    func startUpdatingLocation()
    func stopUpdatingLocation()
    @available(iOSApplicationExtension 9.0, *)
    func requestLocation()
    var distanceFilter: CLLocationDistance {get set}
    var desiredAccuracy: CLLocationAccuracy {get set}
    #if os(iOS)
    var pausesLocationUpdatesAutomatically: Bool {get set}
    @available(iOSApplicationExtension 9.0, *)
    var allowsBackgroundLocationUpdates: Bool {get set}
    func allowDeferredLocationUpdatesUntilTraveled(distance: CLLocationDistance, timeout: NSTimeInterval)
    func disallowDeferredLocationUpdates()
    var activityType: CLActivityType {get set}
    #endif
    
    #if os(iOS) || os(OSX)
    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()
    #endif
    
    #if os(iOS)
    func startUpdatingHeading()
    func stopUpdatingHeading()
    func dismissHeadingCalibrationDisplay()
    var headingFilter: CLLocationDegrees {get set}
    var headingOrientation: CLDeviceOrientation {get set}
    #endif
    
    #if os(iOS) || os(OSX)
    func startMonitoringForRegion(region: CLRegion)
    func stopMonitoringForRegion(region: CLRegion)
    var monitoredRegions: Set<CLRegion> { get }
    var maximumRegionMonitoringDistance: CLLocationDistance { get }
    func requestStateForRegion(region: CLRegion)
    #endif
    
    #if os(iOS)
    var rangedRegions: Set<CLRegion> { get }
    func startRangingBeaconsInRegion(region: CLBeaconRegion)
    func stopRangingBeaconsInRegion(region: CLBeaconRegion)
    #endif
    
    #if os(iOS)
    func startMonitoringVisits()
    func stopMonitoringVisits()
    #endif
    
    // bridged delegate methods
    var didFailWithError: ((CLLocationManager, NSError) -> Void)? {get set}
    var didChangeAuthorizationStatus: ((CLLocationManager, CLAuthorizationStatus)->Void)? {get set}
    
    #if os(OSX)
    var didUpdateLocations: ((CLLocationManager, [AnyObject]) -> Void)? {get set}
    #else
    var didUpdateLocations: ((CLLocationManager, [CLLocation]) -> Void)? {get set}
    #endif
    
    #if os(iOS) || os(OSX)
    var didFinishDeferredUpdatesWithError: ((CLLocationManager, NSError?) -> Void)? {get set}
    var didEnterRegion: ((CLLocationManager, CLRegion) -> Void)? {get set}
    var didExitRegion: ((CLLocationManager, CLRegion) -> Void)? {get set}
    var monitoringDidFailForRegion: ((CLLocationManager, CLRegion?, NSError) -> Void)? {get set}
    var didDetermineState:((CLLocationManager, CLRegionState, CLRegion) -> Void)? {get set}
    var didStartMonitoringForRegion:((CLLocationManager, CLRegion) -> Void)? {get set}
    #endif
    
    #if os(iOS)
    var didPausedUpdate:((CLLocationManager) -> Void)? {get set}
    var didResumeUpdate:((CLLocationManager) -> Void)? {get set}
    var displayHeadingCalibration:Bool {get set}
    var didUpdateHeading: ((CLLocationManager, CLHeading) -> Void)? {get set}
    var didRangeBeaconsInRegion:((CLLocationManager, [CLBeacon], CLBeaconRegion) -> Void)? {get set}
    var rangingBeaconsDidFailForRegion:((CLLocationManager, CLBeaconRegion, NSError) -> Void)? {get set}
    var didVisit:((CLLocationManager, CLVisit) -> Void)? {get set}
    #endif
}
extension LocationManagerBridge{
    //class methods on CLLocationManager type
    static func authorizationStatus() -> CLAuthorizationStatus{
        return CLLocationManager.authorizationStatus()
    }
    static func locationServicesEnabled() -> Bool{
        return CLLocationManager.locationServicesEnabled()
    }
    
    #if os(iOS) || os(OSX)
    static func significantLocationChangeMonitoringAvailable() -> Bool{
        return CLLocationManager.significantLocationChangeMonitoringAvailable()
    }
    static func isMonitoringAvailableForClass(regionClass: AnyClass) -> Bool{
        return CLLocationManager.isMonitoringAvailableForClass(regionClass)
    }
    #endif
    
    #if os(iOS)
    static func deferredLocationUpdatesAvailable() -> Bool{
        return CLLocationManager.deferredLocationUpdatesAvailable()
    }
    static func headingAvailable() -> Bool{
        return CLLocationManager.headingAvailable()
    }
    static func isRangingAvailable() -> Bool{
        return CLLocationManager.isRangingAvailable()
    }
    #endif
}

class Bridge:NSObject, LocationManagerBridge, CLLocationManagerDelegate{
    private let manager:CLLocationManager

    //instance methods on CLLocationManager instance
    #if os(iOS) || os(watchOS) || os(tvOS)
    func requestWhenInUseAuthorization(){
        manager.requestWhenInUseAuthorization()
    }
    #endif
    #if os(iOS) || os(watchOS)
    func requestAlwaysAuthorization(){
        manager.requestAlwaysAuthorization()
    }
    #endif
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    var location: CLLocation? {
        get{
            return manager.location
        }
    }
    #endif
    
    func startUpdatingLocation(){
        manager.startUpdatingLocation()
    }
    func stopUpdatingLocation(){
        manager.stopUpdatingLocation()
    }
    @available(iOSApplicationExtension 9.0, *)
    func requestLocation(){
        manager.requestLocation()
    }
    var distanceFilter: CLLocationDistance{
        get{
            return manager.distanceFilter
        }
        set{
            return manager.distanceFilter = newValue
        }
    }
    var desiredAccuracy: CLLocationAccuracy{
        get{
            return manager.desiredAccuracy
        }
        set{
            return manager.desiredAccuracy = newValue
        }
    }
    #if os(iOS)
    var pausesLocationUpdatesAutomatically: Bool{
        get{
            return manager.pausesLocationUpdatesAutomatically
        }
        set{
            return manager.pausesLocationUpdatesAutomatically = newValue
        }
    }
    @available(iOSApplicationExtension 9.0, *)
    var allowsBackgroundLocationUpdates: Bool {
        get{
            return manager.allowsBackgroundLocationUpdates
        }
        set{
            return manager.allowsBackgroundLocationUpdates = newValue
        }
    }
    func allowDeferredLocationUpdatesUntilTraveled(distance: CLLocationDistance, timeout: NSTimeInterval){
        manager.allowDeferredLocationUpdatesUntilTraveled(distance, timeout: timeout)
    }
    func disallowDeferredLocationUpdates(){
        manager.disallowDeferredLocationUpdates()
    }
    var activityType: CLActivityType {
        get{
            return manager.activityType
        }
        set{
            return manager.activityType = newValue
        }
    }
    #endif
    
    #if os(iOS) || os(OSX)
    func startMonitoringSignificantLocationChanges(){
        manager.startMonitoringSignificantLocationChanges()
    }
    func stopMonitoringSignificantLocationChanges(){
        manager.stopMonitoringSignificantLocationChanges()
    }
    #endif
    
    #if os(iOS)
    func startUpdatingHeading(){
        manager.startUpdatingHeading()
    }
    func stopUpdatingHeading(){
        manager.stopUpdatingHeading()
    }
    func dismissHeadingCalibrationDisplay(){
        manager.dismissHeadingCalibrationDisplay()
    }
    var headingFilter: CLLocationDegrees {
        get{
            return manager.headingFilter
        }
        set{
            return manager.headingFilter = newValue
        }
    }
    var headingOrientation: CLDeviceOrientation {
        get{
            return manager.headingOrientation
        }
        set{
            return manager.headingOrientation = newValue
        }
    }
    #endif
    
    #if os(iOS) || os(OSX)
    func startMonitoringForRegion(region: CLRegion){
        manager.startMonitoringForRegion(region)
    }
    func stopMonitoringForRegion(region: CLRegion){
        manager.stopMonitoringForRegion(region)
    }
    var monitoredRegions: Set<CLRegion> {
        get{
            return manager.monitoredRegions
        }
    }
    var maximumRegionMonitoringDistance: CLLocationDistance {
        get{
            return manager.maximumRegionMonitoringDistance
        }
    }
    func requestStateForRegion(region: CLRegion){
        manager.requestStateForRegion(region)
    }
    #endif
    
    #if os(iOS)
    var rangedRegions: Set<CLRegion> {
        get{
            return manager.rangedRegions
        }
    }
    func startRangingBeaconsInRegion(region: CLBeaconRegion){
        manager.startRangingBeaconsInRegion(region)
    }
    func stopRangingBeaconsInRegion(region: CLBeaconRegion){
        manager.stopRangingBeaconsInRegion(region)
    }
    #endif
    
    #if os(iOS)
    func startMonitoringVisits(){
        manager.startMonitoringVisits()
    }
    func stopMonitoringVisits(){
        manager.stopMonitoringVisits()
    }
    #endif
    
    
    var didFailWithError: ((CLLocationManager, NSError) -> Void)?
    var didChangeAuthorizationStatus: ((CLLocationManager, CLAuthorizationStatus)->Void)?
    
    #if os(OSX)
    var didUpdateLocations: ((CLLocationManager, [AnyObject]) -> Void)?
    #else
    var didUpdateLocations: ((CLLocationManager, [CLLocation]) -> Void)?
    #endif
    
    #if os(iOS) || os(OSX)
    var didFinishDeferredUpdatesWithError: ((CLLocationManager, NSError?) -> Void)?
    var didEnterRegion: ((CLLocationManager, CLRegion) -> Void)?
    var didExitRegion: ((CLLocationManager, CLRegion) -> Void)?
    var monitoringDidFailForRegion: ((CLLocationManager, CLRegion?, NSError) -> Void)?
    var didDetermineState:((CLLocationManager, CLRegionState, CLRegion) -> Void)?
    var didStartMonitoringForRegion:((CLLocationManager, CLRegion) -> Void)?
    #endif
    
    #if os(iOS)
    var didPausedUpdate:((CLLocationManager) -> Void)?
    var didResumeUpdate:((CLLocationManager) -> Void)?
    var displayHeadingCalibration:Bool = false
    var didUpdateHeading: ((CLLocationManager, CLHeading) -> Void)?
    var didRangeBeaconsInRegion:((CLLocationManager, [CLBeacon], CLBeaconRegion) -> Void)?
    var rangingBeaconsDidFailForRegion:((CLLocationManager, CLBeaconRegion, NSError) -> Void)?
    var didVisit:((CLLocationManager, CLVisit) -> Void)?
    #endif
    
    override required init(){
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        didFailWithError?(manager, error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        didChangeAuthorizationStatus?(manager, status)
    }
    
    #if os(OSX)
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        didUpdateLocations?(manager, locations)
    }
    #else
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations?(manager, locations)
    }
    #endif
}

#if os(iOS) || os(OSX)
    extension Bridge{
        func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
            didDetermineState?(manager, state, region)
        }
        
        func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
            didEnterRegion?(manager, region)
        }
        
        func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
            didExitRegion?(manager, region)
        }
        
        func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
            monitoringDidFailForRegion?(manager, region, error)
        }
        
        func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
            didStartMonitoringForRegion?(manager, region)
        }
    }
#endif

#if os(iOS)
    extension Bridge{
        func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
            didFinishDeferredUpdatesWithError?(manager, error)
        }
        
        func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
            didPausedUpdate?(manager)
        }
        
        func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
            didResumeUpdate?(manager)
        }
        
        func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
            return displayHeadingCalibration
        }
        
        func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            didUpdateHeading?(manager, newHeading)
        }
        
        func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
            didRangeBeaconsInRegion?(manager, beacons, region)
        }
        
        func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError){
            rangingBeaconsDidFailForRegion?(manager, region, error)
        }
        
        func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
            didVisit?(manager, visit)
        }
    }
#endif
    