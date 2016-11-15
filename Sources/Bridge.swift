//
//  Bridge.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation
import CoreLocation

class CLLocationManagerBridge: CLLocationManager, CLLocationManagerDelegate{
    var didFailWithError: ((CLLocationManager, NSError) -> Void)?
    var didChangeAuthorizationStatus: ((CLLocationManager, CLAuthorizationStatus)->Void)?
    var didUpdateLocations: ((CLLocationManager, [CLLocation]) -> Void)?
    
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
    
    required override init() {
        super.init()
        self.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError?(manager, error as NSError)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorizationStatus?(manager, status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations?(manager, locations)
    }
}

#if os(iOS) || os(OSX)
extension CLLocationManagerBridge{

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
extension CLLocationManagerBridge{

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
