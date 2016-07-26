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
            headingUpdateService.headingFilter(20.0)
            expect(self.headingUpdateService.headingFilter).to(equal(bridge.headingFilter))
            expect(self.headingUpdateService.headingFilter).to(equal(20.0))
        }
        func testGetSetHeadingOrientation() {
            headingUpdateService.headingOrientation(CLDeviceOrientation.FaceDown)
            expect(self.headingUpdateService.headingOrientation).to(equal(bridge.headingOrientation))
            expect(self.headingUpdateService.headingOrientation).to(equal(CLDeviceOrientation.FaceDown))
        }
        func testGetSetDisplayHeadingCalibration() {
            headingUpdateService.displayHeadingCalibration(false)
            expect(self.headingUpdateService.displayHeadingCalibration).to(equal(bridge.displayHeadingCalibration))
            expect(self.headingUpdateService.displayHeadingCalibration).to(beFalse())
        }
        func testGetSetTrueHeading() {
            headingUpdateService.trueHeading(true)
            expect(self.headingUpdateService.trueHeading).to(beTrue())
            expect(self.bridge.updatingLocation).to(beTrue())
            headingUpdateService.trueHeading(false)
            expect(self.headingUpdateService.trueHeading).to(beFalse())
            expect(self.bridge.updatingLocation).to(beFalse())
        }
        //TODO - Figure out a way to mock CLHeading object
    }
#endif
