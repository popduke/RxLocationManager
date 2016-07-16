//
//  Bridge.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
#if os(iOS)
    import Foundation
    import CoreLocation
    
    class Bridge:NSObject, CLLocationManagerDelegate{
        let manager:CLLocationManager
        var didFailWithError: ((CLLocationManager, NSError) -> Void)?
        var didChangeAuthorizationStatus: ((CLLocationManager, CLAuthorizationStatus)->Void)?
        var didUpdateLocations: ((CLLocationManager, [CLLocation]) -> Void)?
        var didFinishDeferredUpdatesWithError: ((CLLocationManager, NSError?) -> Void)?
        var didEnterRegion: ((CLLocationManager, CLRegion) -> Void)?
        var didExitRegion: ((CLLocationManager, CLRegion) -> Void)?
        var monitoringDidFailForRegion: ((CLLocationManager, CLRegion?, NSError) -> Void)?
        var didStartMonitoringForRegion:((CLLocationManager, CLRegion) -> Void)?
        var didPausedUpdate:((CLLocationManager) -> Void)?
        var didResumeUpdate:((CLLocationManager) -> Void)?
        var displayHeadingCalibration:Bool = false
        var didUpdateHeading: ((CLLocationManager, CLHeading) -> Void)?
        var didDetermineState:((CLLocationManager, CLRegionState, CLRegion) -> Void)?
        var didRangeBeaconsInRegion:((CLLocationManager, [CLBeacon], CLBeaconRegion) -> Void)?
        var rangingBeaconsDidFailForRegion:((CLLocationManager, CLBeaconRegion, NSError) -> Void)?
        var didVisit:((CLLocationManager, CLVisit) -> Void)?
        
        override init(){
            manager = CLLocationManager()
            super.init()
            manager.delegate = self
        }
        
        func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
            didFailWithError?(manager, error)
        }
        
        func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            didUpdateLocations?(manager, locations)
        }
        
        func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
            didFinishDeferredUpdatesWithError?(manager, error)
        }
        
        func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            didChangeAuthorizationStatus?(manager, status)
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
        
        func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
            didDetermineState?(manager, state, region)
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