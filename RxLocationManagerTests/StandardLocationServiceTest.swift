//
//  StandardLocationServiceTest.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/24.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import XCTest
import Nimble
import CoreLocation
import RxSwift
@testable
import RxLocationManager

class StandardLocationServiceTest: XCTestCase{
    var standardLocationService:DefaultStandardLocationService!
    var disposeBag: DisposeBag!
    var bridgeForLocation:LocationManagerStub!
    var bridgeForLocating:LocationManagerStub!
    var dummyLocationMgr:CLLocationManager!
    override func setUp() {
        standardLocationService = DefaultStandardLocationService(bridgeClass:LocationManagerStub.self)
        bridgeForLocation = standardLocationService.locMgrForLocation as! LocationManagerStub
        bridgeForLocating = standardLocationService.locMgrForLocating as! LocationManagerStub
        dummyLocationMgr = CLLocationManager()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
    }
    
    func testGetSetDistanceFilter(){
        standardLocationService.distanceFilter(10.0)
        expect(self.standardLocationService.locMgrForLocation.distanceFilter).to(equal(standardLocationService.locMgrForLocating.distanceFilter))
        expect(self.standardLocationService.locMgrForLocation.distanceFilter).to(equal(10.0))
    }
    
    func testGetSetDesiredAccuracy(){
        standardLocationService.desiredAccuracy(100.0)
        expect(self.standardLocationService.desiredAccuracy).to(equal(100.0))
    }
    #if os(iOS)
    func testGetSetPausesLocationUpdatesAutomatically(){
        standardLocationService.pausesLocationUpdatesAutomatically(true)
        expect(self.standardLocationService.locMgrForLocating.pausesLocationUpdatesAutomatically).to(equal(true))
        
    }
    
    func testEnableDeferredLocationUpdates(){
        standardLocationService.allowDeferredLocationUpdates(untilTraveled: 100, timeout: 60)
        expect((self.standardLocationService.locMgrForLocating as! LocationManagerStub).currentlyDeferedSetting! == (100,60)).to(beTrue())
    }
    
    func testDisableDeferredLocationUpdates(){
        standardLocationService.allowDeferredLocationUpdates(untilTraveled: 100, timeout: 60)
        standardLocationService.disallowDeferredLocationUpdates()
        expect((self.standardLocationService.locMgrForLocating as! LocationManagerStub).currentlyDeferedSetting == nil).to(beTrue())
    }
    
    func testGetSetAllowsBgLocationUpdates(){
        standardLocationService.allowsBackgroundLocationUpdates(true)
        expect(self.standardLocationService.locMgrForLocating.allowsBackgroundLocationUpdates).to(equal(true))
        
    }
    
    func testGetSetActivityType(){
        standardLocationService.activityType(CLActivityType.AutomotiveNavigation)
        expect(self.standardLocationService.locMgrForLocating.activityType).to(equal(CLActivityType.AutomotiveNavigation))
    }
    #endif
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    func testCurrentLocationObservable(){
        let xcTextExpectation1 = self.expectationWithDescription("GotLocationAndComplete")
        standardLocationService.located
            .subscribe{
                event in
                switch event{
                case .Next(let location):
                    expect(location).to(equal(Locations.London))
                case .Completed:
                    xcTextExpectation1.fulfill()
                case .Error:
                    expect(true).to(beFalse(), description: "Error should not get called when location is reported")
                }
            }
            .addDisposableTo(disposeBag)
        bridgeForLocation.didUpdateLocations!(dummyLocationMgr, [Locations.London])
        self.waitForExpectationsWithTimeout(5, handler:nil)
        
        let xcTextExpectation2 = self.expectationWithDescription("GotError")
        standardLocationService.located
            .subscribe{
                event in
                switch event{
                case .Next:
                    expect(true).to(beFalse(), description: "Next should not get called when error is reported")
                case .Completed:
                    expect(true).to(beFalse(), description: "Completed should not get called when error is reported")
                case .Error(let error as NSError):
                    expect(error.domain == CLError.LocationUnknown.toNSError().domain).to(beTrue())
                    expect(error.code == CLError.LocationUnknown.toNSError().code).to(beTrue())
                    xcTextExpectation2.fulfill()
                default:
                    expect(true).to(beFalse(), description: "You should not be here")
                }
            }
            .addDisposableTo(disposeBag)
        bridgeForLocation.didFailWithError!(dummyLocationMgr, CLError.LocationUnknown.toNSError())
        self.waitForExpectationsWithTimeout(5, handler:nil)
    }
    #endif
    #if os(iOS) || os(OSX)
    func testLocatingObservable(){
        let xcTextExpectation = self.expectationWithDescription("GotSeriesOfLocations")
        var n = 1
        standardLocationService.locating
            .subscribe{
                event in
                switch event{
                case .Next(let location):
                    switch n{
                    case 1:
                        expect(location.last!).to(equal(Locations.London))
                        n += 1
                    case 2:
                        expect(location.last!).to(equal(Locations.Johnannesburg))
                        n += 1
                    case 3:
                        expect(location.last!).to(equal(Locations.Moscow))
                        xcTextExpectation.fulfill()
                    default:
                        expect(true).to(beFalse(), description: "You should not be here")
                    }
                case .Completed:
                    expect(true).to(beFalse(), description: "Completed should not get called when observing location updating")
                case .Error:
                    expect(true).to(beFalse(), description: "Error should not get called when location is reported")
                }
            }
            .addDisposableTo(disposeBag)
        expect(self.bridgeForLocating.updatingLocation).to(beTrue())
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.London])
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.Johnannesburg])
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.Moscow])
        self.waitForExpectationsWithTimeout(100, handler:nil)
    }
    
    func testLocatingObservableWithIgnorableError(){
        let xcTextExpectation = self.expectationWithDescription("GotSeriesOfLocationsAndIgnoreLocationUnknownError")
        var n = 1
        standardLocationService.locating
            .subscribe{
                event in
                switch event{
                case .Next(let location):
                    switch n{
                    case 1:
                        expect(location.last!).to(equal(Locations.London))
                        n += 1
                    case 2:
                        expect(location.last!).to(equal(Locations.Johnannesburg))
                        n += 1
                    case 3:
                        expect(location.last!).to(equal(Locations.Moscow))
                        xcTextExpectation.fulfill()
                    default:
                        expect(true).to(beFalse(), description: "You should not be here")
                    }
                case .Completed:
                    expect(true).to(beFalse(), description: "Completed should not get called when observing location updating")
                case .Error:
                    expect(true).to(beFalse(), description: "Error should not get called when location is reported")
                }
            }
            .addDisposableTo(disposeBag)
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.London])
        bridgeForLocating.didFailWithError!(dummyLocationMgr, CLError.LocationUnknown.toNSError())
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.Johnannesburg])
        bridgeForLocating.didFailWithError!(dummyLocationMgr, CLError.LocationUnknown.toNSError())
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.Moscow])
        bridgeForLocating.didFailWithError!(dummyLocationMgr, CLError.LocationUnknown.toNSError())
        self.waitForExpectationsWithTimeout(5, handler:nil)
    }
    
    func testLocatingObservableWithError(){
        let xcTextExpectation = self.expectationWithDescription("GotSeriesOfLocationsAndNonIgnorableError")
        var n = 1
        standardLocationService.locating
            .subscribe{
                event in
                switch event{
                case .Next(let location):
                    switch n{
                    case 1:
                        expect(location.last!).to(equal(Locations.London))
                        n += 1
                    case 2:
                        expect(location.last!).to(equal(Locations.Johnannesburg))
                        n += 1
                    case 3:
                        expect(true).to(beFalse(), description: "You should not be here")
                    default:
                        expect(true).to(beFalse(), description: "You should not be here")
                    }
                case .Completed:
                    expect(true).to(beFalse(), description: "Completed should not get called when observing location updating")
                case .Error:
                    xcTextExpectation.fulfill()
                }
            }
            .addDisposableTo(disposeBag)
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.London])
        bridgeForLocating.didFailWithError!(dummyLocationMgr, CLError.LocationUnknown.toNSError())
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.Johnannesburg])
        bridgeForLocating.didFailWithError!(dummyLocationMgr, CLError.Denied.toNSError())
        bridgeForLocating.didUpdateLocations!(dummyLocationMgr, [Locations.Moscow])
        self.waitForExpectationsWithTimeout(5, handler:nil)
    }
    #endif
    
    #if os(iOS)
    func testPausedObservable(){
        let xcTextExpectation = self.expectationWithDescription("ObservableOfIsPaused")
        var n = 1
        standardLocationService.isPaused
            .subscribe{
                event in
                switch event{
                case .Next(let isPaused):
                    switch n{
                    case 1:
                        expect(isPaused).to(beTrue())
                        n += 1
                    case 2:
                        expect(isPaused).to(beFalse())
                        xcTextExpectation.fulfill()
                        n += 1
                    default:
                        expect(true).to(beFalse(), description: "You should not be here")
                    }
                case .Completed:
                    expect(true).to(beFalse(), description: "Completed should not get called for this observable")
                case .Error:
                    expect(true).to(beFalse(), description: "Error should not get called for this observable")
                }
            }
            .addDisposableTo(disposeBag)
        bridgeForLocating.didPausedUpdate!(dummyLocationMgr)
        bridgeForLocating.didResumeUpdate!(dummyLocationMgr)
        self.waitForExpectationsWithTimeout(5, handler:nil)
    }
    
    func testDeferredUpdateErrorObservable(){
        let xcTextExpectation = self.expectationWithDescription("ObservableOfIsPaused")
        standardLocationService.deferredUpdateFinished
            .subscribe{
                event in
                switch event{
                case .Next(let error):
                    expect(error!.code == CLError.DeferredAccuracyTooLow.toNSError().code).to(beTrue())
                    xcTextExpectation.fulfill()
                case .Completed:
                    expect(true).to(beFalse(), description: "Completed should not get called for this observable")
                case .Error:
                    expect(true).to(beFalse(), description: "Error should not get called for this observable")
                }
            }
            .addDisposableTo(disposeBag)
        bridgeForLocating.didFinishDeferredUpdatesWithError!(dummyLocationMgr, CLError.DeferredAccuracyTooLow.toNSError())
        self.waitForExpectationsWithTimeout(5, handler:nil)
    }
    #endif
}
