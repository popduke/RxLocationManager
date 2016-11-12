//
//  MonitoringVisitsServiceTest.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/27.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import XCTest
import RxSwift
import CoreLocation
import Nimble
@testable
import RxLocationManager
#if os(iOS)
class MonitoringVisitsServiceTest: XCTestCase {
    var monitoringVisitsService: DefaultMonitoringVisitsService!
    var bridge: LocationManagerStub!
    var disposeBag: DisposeBag!
    override func setUp() {
        monitoringVisitsService = DefaultMonitoringVisitsService(bridgeClass: LocationManagerStub.self)
        bridge = monitoringVisitsService.locMgr as! LocationManagerStub
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
    }

    func testVisitsObservable() {
        let xcTestExpectation = self.expectation(description: "Get one visited place")
        monitoringVisitsService.visiting
            .subscribe(onNext: {
                visit in
                expect(visit == Visits.one).to(beTrue())
                xcTestExpectation.fulfill()
            })
            .addDisposableTo(disposeBag)
        self.bridge.didVisit!(dummyLocationManager, Visits.one)
        self.waitForExpectations(timeout: 50, handler: nil)

    }
}
#endif
