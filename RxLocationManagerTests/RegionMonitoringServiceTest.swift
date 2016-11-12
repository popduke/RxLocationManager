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
            _ = regionMonitoringService.startMonitoringForRegions([GeoRegions.London, GeoRegions.Johnannesburg])
            expect(self.bridge.currentMonitoredRegions).to(equal([GeoRegions.London, GeoRegions.Johnannesburg]))
        }
        
        func testStopMonitoringForRegions() {
            _ = regionMonitoringService.startMonitoringForRegions([GeoRegions.London, GeoRegions.Johnannesburg])
            _ = regionMonitoringService.stopMonitoringForRegions([GeoRegions.London])
            expect(self.bridge.currentMonitoredRegions).to(equal([GeoRegions.Johnannesburg]))
        }
        
        func testStopAllMonitoringForRegions() {
            _ = regionMonitoringService.startMonitoringForRegions([GeoRegions.London, GeoRegions.Johnannesburg])
            _ = regionMonitoringService.stopMonitoringForAllRegions()
            expect(self.bridge.currentMonitoredRegions.count).to(equal(0))
        }
        
        func testRequestStateForRegion() {
            _ = regionMonitoringService.requestRegionsState([GeoRegions.London, GeoRegions.Johnannesburg])
            expect(self.bridge.currentRegionStateRequests).to(equal([GeoRegions.London, GeoRegions.Johnannesburg]))
        }
        
        #if os(iOS)
        func testStartRangingBeaconsInRegion(){
            _ = regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.one)
            _ = regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.two)
            expect(self.bridge.currangRangedBeaconRegions).to(equal([BeaconRegions.one, BeaconRegions.two]))
            expect(self.bridge.currangRangedBeaconRegions).to(equal(regionMonitoringService.rangedRegions))
        }
        
        func testStopRangingBeaconsInRegion(){
            _ = regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.one)
            _ = regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.two)
            _ = regionMonitoringService.startRangingBeaconsInRegion(BeaconRegions.three)
            _ = regionMonitoringService.stopRangingBeaconsInRegion(BeaconRegions.three)
            expect(self.bridge.currangRangedBeaconRegions).to(equal([BeaconRegions.one, BeaconRegions.two]))
        }
        #endif
        
        func testGetMaximumRegionMonitoringDistance(){
            expect(self.regionMonitoringService.maximumRegionMonitoringDistance).to(equal(200))
        }
        
        func testMonitoredRegionsObservable(){
            self.bridge.currentMonitoredRegions.insert(GeoRegions.London)
            let xcTestExpectation = self.expectation(description: "Get one monitored region")
            var n = 1
            regionMonitoringService.monitoredRegions
                .subscribe(onNext: {
                    regions in
                    if n == 1{
                        expect(regions).to(equal([GeoRegions.London]))
                        n += 1
                    }else{
                        expect(regions).to(equal([GeoRegions.London, GeoRegions.Johnannesburg]))
                        xcTestExpectation.fulfill()
                    }
                })
                .addDisposableTo(disposeBag)
            
            self.bridge.currentMonitoredRegions.insert(GeoRegions.Johnannesburg)
            self.bridge.didStartMonitoringForRegion!(dummyLocationManager, GeoRegions.Johnannesburg)
            self.waitForExpectations(timeout: 50, handler: nil)
        }
        
        
        func testRegionEnteringEventObservable(){
            let xcTestExpectation = self.expectation(description: "Get one monitored region enter event")
            regionMonitoringService.entering
                .subscribe(onNext: {
                    region in
                    expect(region).to(equal(GeoRegions.London))
                    xcTestExpectation.fulfill()
                })
                .addDisposableTo(disposeBag)
            self.bridge.didEnterRegion!(dummyLocationManager, GeoRegions.London)
            self.waitForExpectations(timeout: 50, handler: nil)
        }
        
        func testRegionExitingEventObservable(){
            let xcTestExpectation = self.expectation(description: "Get one monitored region exit event")
            regionMonitoringService.exiting
                .subscribe(onNext: {
                    region in
                    expect(region).to(equal(GeoRegions.London))
                    xcTestExpectation.fulfill()
                })
                .addDisposableTo(disposeBag)
            self.bridge.didExitRegion!(dummyLocationManager, GeoRegions.London)
            self.waitForExpectations(timeout: 50, handler: nil)
        }
        
        func testDeterminedRegionStateObservable(){
            let xcTestExpectation = self.expectation(description: "Determined state for one monitored region")
            regionMonitoringService.determinedRegionState
                .subscribe(onNext: {
                    region, state in
                    expect(region).to(equal(GeoRegions.London))
                    expect(state).to(equal(CLRegionState.inside))
                    xcTestExpectation.fulfill()
                })
                .addDisposableTo(disposeBag)
            self.bridge.didDetermineState!(dummyLocationManager, CLRegionState.inside,GeoRegions.London)
            self.waitForExpectations(timeout: 50, handler: nil)
        }
        
        func testErrorObservableWithMonitoringError(){
            let xcTestExpectation = self.expectation(description: "Get error during monitoring region")
            regionMonitoringService.error
                .subscribe(onNext: {
                    region, error in
                    expect(region!).to(equal(GeoRegions.London))
                    expect(error).to(equal(CLError.regionMonitoringFailure.toNSError()))
                    xcTestExpectation.fulfill()
                })
                .addDisposableTo(disposeBag)
            self.bridge.monitoringDidFailForRegion!(dummyLocationManager, GeoRegions.London, CLError.regionMonitoringFailure.toNSError())
            self.waitForExpectations(timeout: 50, handler: nil)
        }
        
        #if os(iOS)
        func testErrorObservableWithRangingError(){
            let xcTestExpectation = self.expectation(description: "Get error during ranging beacons")
            regionMonitoringService.error.subscribe(onNext: {
                region, error in
                expect(region!).to(equal(BeaconRegions.one))
                expect(error).to(equal(CLError.Code.rangingFailure.toNSError()))
                xcTestExpectation.fulfill()
            })
            .addDisposableTo(disposeBag)
            self.bridge.rangingBeaconsDidFailForRegion!(dummyLocationManager, BeaconRegions.one, CLError.Code.rangingFailure.toNSError())
            self.waitForExpectations(timeout: 50, handler: nil)
        }
        
        func testRangingObservable(){
            let xcTestExpectation = self.expectation(description: "Get ranged beacons")
            regionMonitoringService.ranging
                .subscribe(onNext: {
                    beacons, beaconRegion in
                    expect(beacons.count).to(equal(0))
                    expect(beaconRegion).to(equal(BeaconRegions.one))
                    xcTestExpectation.fulfill()
                })
                .addDisposableTo(disposeBag)
            self.bridge.didRangeBeaconsInRegion!(dummyLocationManager, [], BeaconRegions.one)
            self.waitForExpectations(timeout: 50, handler: nil)
        }
        #endif
    }
#endif
