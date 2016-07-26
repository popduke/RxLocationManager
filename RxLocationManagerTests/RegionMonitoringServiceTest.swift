//
//  RegionMonitoringServiceTest.swift
//  RxLocationManager
//
//  Created by HaoYu on 16/7/26.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import XCTest
import RxSwift
import CoreLocation
import Nimble
@testable
import RxLocationManager
#if os(iOS) || os(OSX)
class RegionMonitoringServiceTest: XCTestCase {
    var regionMonitoringService: DefaultRegionMonitoringService!
    var bridge: LocationManagerStub!
    var disposeBag: DisposeBag!
    override func setUp() {
        regionMonitoringService = DefaultRegionMonitoringService(bridgeClass: LocationManagerStub.self)
        bridge = regionMonitoringService.locMgr as! LocationManagerStub
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
    }
    
    func testStartMonitoringForRegions() {
        regionMonitoringService.startMonitoringForRegions([GeoRegions.London, GeoRegions.Johnannesburg])
        expect(self.bridge.currentMonitoredRegions).to(equal([GeoRegions.London, GeoRegions.Johnannesburg]))
    }
    
    func testStopMonitoringForRegions() {
        regionMonitoringService.startMonitoringForRegions([GeoRegions.London, GeoRegions.Johnannesburg])
        regionMonitoringService.stopMonitoringForRegions([GeoRegions.London])
        expect(self.bridge.currentMonitoredRegions).to(equal([GeoRegions.Johnannesburg]))
    }
    
    func testStopAllMonitoringForRegions() {
        regionMonitoringService.startMonitoringForRegions([GeoRegions.London, GeoRegions.Johnannesburg])
        regionMonitoringService.stopMonitoringForAllRegions()
        expect(self.bridge.currentMonitoredRegions.count).to(equal(0))
    }
    
    func testRequestStateForRegion() {
        regionMonitoringService.requestRegionsState([GeoRegions.London, GeoRegions.Johnannesburg])
        expect(self.bridge.currentRegionStateRequests).to(equal([GeoRegions.London, GeoRegions.Johnannesburg]))
    }
    
    func testStartRangingBeaconsInRegion(){
        regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.one)
        regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.two)
        expect(self.bridge.currangRangedBeaconRegions).to(equal([BeaconRegions.one, BeaconRegions.two]))
        expect(self.bridge.currangRangedBeaconRegions).to(equal(regionMonitoringService.rangedRegions))
    }
    
    func testStopRangingBeaconsInRegion(){
        regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.one)
        regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.two)
        regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.three)
        regionMonitoringService.stopRangingBeaconsInRegion(BeaconRegions.three)
        expect(self.bridge.currangRangedBeaconRegions).to(equal([BeaconRegions.one, BeaconRegions.two]))
    }
    
    func testGetMaximumRegionMonitoringDistance(){
        expect(self.regionMonitoringService.maximumRegionMonitoringDistance).to(equal(200))
    }
    
    func testMonitoredRegionsObservable(){
        
    }
    
    func testRegionEnteringEventObservable(){
        
    }
    
    func testRegionExitingEventObservable(){
        
    }
    
    func testDeterminedRegionStateObservable(){
        
    }
    
    func testErrorObservable(){
        
    }
    
    func testRangingObservable(){
        
    }
}
#endif
