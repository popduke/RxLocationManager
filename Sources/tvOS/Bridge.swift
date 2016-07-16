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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        didChangeAuthorizationStatus?(manager, status)
    }
}
