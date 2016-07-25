//
//  Fixtures.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/24.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation
import CoreLocation

struct Locations{
    static let London = CLLocation(latitude: 51.50, longitude: -0.13)
    static let Johnannesburg = CLLocation(latitude: -26.20, longitude: 28.05)
    static let Moscow = CLLocation(latitude: 55.75, longitude: 37.62)
    static let Mumbai = CLLocation(latitude: 19.02, longitude: 72.86)
    static let Tokyo = CLLocation(latitude: 35.70, longitude: 139.78)
    static let Sydney = CLLocation(latitude: -33.86, longitude: 151.21)
}

extension CLError{
    func toNSError() -> NSError{
        return NSError(domain: kCLErrorDomain, code: rawValue, userInfo: nil)
    }
}