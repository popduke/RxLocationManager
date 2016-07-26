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

struct GeoRegions{
    static let London = CLCircularRegion(center: Locations.London.coordinate, radius: 100, identifier: "London")
    static let Johnannesburg = CLCircularRegion(center: Locations.Johnannesburg.coordinate, radius: 100, identifier: "Johnannesburg")
    static let Moscow = CLCircularRegion(center: Locations.Moscow.coordinate, radius: 100, identifier: "Moscow")
    static let Mumbai = CLCircularRegion(center: Locations.Mumbai.coordinate, radius: 100, identifier: "Mumbai")
    static let Tokyo = CLCircularRegion(center: Locations.Tokyo.coordinate, radius: 100, identifier: "Tokyo")
    static let Sydney = CLCircularRegion(center: Locations.Sydney.coordinate, radius: 100, identifier: "Sydney")
}

struct BeaconRegions{
    static let one = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "436F7E14-D361-4D9E-8A0B-9C5B780788C0")!, identifier: "one")
    static let two = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "A36C2C84-CFC8-4E2F-BEE8-9036A7CBD26D")!, identifier: "two")
    static let three = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "6CE0D127-42AC-45B9-839C-0B6AD53EBE11")!, identifier: "three")
}

extension CLError{
    func toNSError() -> NSError{
        return NSError(domain: kCLErrorDomain, code: rawValue, userInfo: nil)
    }
}