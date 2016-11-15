//
//  HeadingUpdateServiceTest.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/25.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import XCTest
import RxSwift
import CoreLocation
import Nimble
@testable
import RxLocationManager
#if os(iOS)
    class HeadingUpdateServiceTest: XCTestCase {
        var headingUpdateService: DefaultHeadingUpdateService!
        var bridge: LocationManagerStub!
        var disposeBag: DisposeBag!
        override func setUp() {
            headingUpdateService = DefaultHeadingUpdateService(bridgeClass: LocationManagerStub.self)
            bridge = headingUpdateService.locMgr as! LocationManagerStub
            disposeBag = DisposeBag()
        }
        
        override func tearDown() {
            disposeBag = nil
        }
        
        func testGetSetHeadingFilter() {
            _ = headingUpdateService.headingFilter(20.0)
            expect(self.headingUpdateService.headingFilter).to(equal(bridge.headingFilter))
            expect(self.headingUpdateService.headingFilter).to(equal(20.0))
        }
        func testGetSetHeadingOrientation() {
            _ = headingUpdateService.headingOrientation(CLDeviceOrientation.faceDown)
            expect(self.headingUpdateService.headingOrientation).to(equal(bridge.headingOrientation))
            expect(self.headingUpdateService.headingOrientation).to(equal(CLDeviceOrientation.faceDown))
        }
        func testGetSetDisplayHeadingCalibration() {
            _ = headingUpdateService.displayHeadingCalibration(false)
            expect(self.headingUpdateService.displayHeadingCalibration).to(equal(bridge.displayHeadingCalibration))
            expect(self.headingUpdateService.displayHeadingCalibration).to(beFalse())
        }
        func testGetSetTrueHeading() {
            _ = headingUpdateService.startTrueHeading((100, kCLLocationAccuracyKilometer))
            expect(self.bridge.currentDistanceFilter).to(equal(100))
            expect(self.bridge.currentDesiredAccuracy).to(equal(kCLLocationAccuracyKilometer))
            expect(self.bridge.updatingLocation).to(beTrue())
            headingUpdateService.stopTrueHeading()
            expect(self.bridge.updatingLocation).to(beFalse())
        }
        func testHeadingObservable() {
            let xcTestExpectation = self.expectation(description: "Get one heading update")
            headingUpdateService.heading
                .subscribe(onNext: {
                    heading in
                    expect(heading == Headings.north).to(beTrue())
                    xcTestExpectation.fulfill()
                })
                .addDisposableTo(disposeBag)
            self.bridge.didUpdateHeading!(dummyLocationManager, Headings.north)
            self.waitForExpectations(timeout: 50, handler: nil)
        }
    }
#endif
