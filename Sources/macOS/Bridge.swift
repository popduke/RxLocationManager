//
//  Bridge.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation
import CoreLocation

class Bridge:NSObject, CLLocationManagerDelegate{
    let manager:CLLocationManager
    var didFailWithError: ((CLLocationManager, NSError) -> Void)?
    var didChangeAuthorizationStatus: ((CLLocationManager, CLAuthorizationStatus)->Void)?
    
    var didUpdateLocations: ((CLLocationManager, [CLLocation]) -> Void)?
    
    var didEnterRegion: ((CLLocationManager, CLRegion) -> Void)?
    var didExitRegion: ((CLLocationManager, CLRegion) -> Void)?
    var monitoringDidFailForRegion: ((CLLocationManager, CLRegion?, NSError) -> Void)?
    var didDetermineState:((CLLocationManager, CLRegionState, CLRegion) -> Void)?
    var didStartMonitoringForRegion:((CLLocationManager, CLRegion) -> Void)?
    
    
    override init(){
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
