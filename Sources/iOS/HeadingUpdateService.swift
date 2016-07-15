//
//  HeadingUpdateService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

//MARK: HeadingUpdateServiceConfigurable
public protocol HeadingUpdateServiceConfigurable{
    func headingFilter(degrees:CLLocationDegrees) -> HeadingUpdateService
    func headingOrientation(degrees:CLDeviceOrientation) -> HeadingUpdateService
    func displayHeadingCalibration(should:Bool) -> HeadingUpdateService
    func trueHeading(enable:Bool) -> HeadingUpdateService
    var headingFilter: CLLocationDegrees{get}
    var headingOrientation: CLDeviceOrientation{get}
    var displayHeadingCalibration: Bool{get}
    var trueHeading: Bool{get}
}
//MARK: HeadingUpdateService
public protocol HeadingUpdateService: HeadingUpdateServiceConfigurable{
    var heading: Observable<CLHeading>{get}
    func dismissHeadingCalibrationDisplay() -> Void
    func clone() -> HeadingUpdateService
}

//MARK: DefaultHeadingUpdateService
class DefaultHeadingUpdateService: HeadingUpdateService {
    private let locMgr: Bridge = Bridge()
    private var _trueHeading: Bool = false
    var trueHeading: Bool{
        get{
            return _trueHeading
        }
    }
    var headingFilter: CLLocationDegrees{
        get{
            return locMgr.manager.headingFilter
        }
    }
    var headingOrientation: CLDeviceOrientation{
        get{
            return locMgr.manager.headingOrientation
        }
    }
    var displayHeadingCalibration: Bool{
        get{
            return locMgr.displayHeadingCalibration
        }
    }
    
    var observers = [(id: Int, observer: AnyObserver<CLHeading>)]()
    var heading : Observable<CLHeading>{
        get{
            return Observable.create {
                observer in
                var ownerService: DefaultHeadingUpdateService! = self
                let id = nextId()
                ownerService.observers.append((id, observer))
                if ownerService._trueHeading{
                    ownerService.locMgr.manager.startUpdatingLocation()
                }
                ownerService.locMgr.manager.startUpdatingHeading()
                return AnonymousDisposable {
                    ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                    if(ownerService.observers.count == 0){
                        ownerService.locMgr.manager.stopUpdatingLocation()
                        ownerService.locMgr.manager.stopUpdatingHeading()
                    }
                    ownerService = nil
                }
            }
        }
    }
    
    init(){
        locMgr.didUpdateHeading = {
            [weak self]
            mgr, heading in
            if let copyOfObservers = self?.observers{
                for (_, observer) in copyOfObservers{
                    observer.onNext(heading)
                }
            }
        }
        locMgr.didFailWithError = {
            [weak self]
            mgr, err in
            if let copyOfObservers = self?.observers{
                for (_, observer) in copyOfObservers{
                    observer.onError(err)
                }
            }
        }
    }
    
    deinit{
        print("HeadingUpdateService deinit")
    }
    
    func headingFilter(degrees: CLLocationDegrees) -> HeadingUpdateService {
        locMgr.manager.headingFilter = degrees
        return self
    }
    
    func headingOrientation(degrees: CLDeviceOrientation) -> HeadingUpdateService {
        locMgr.manager.headingOrientation = degrees
        return self
    }
    
    func displayHeadingCalibration(should: Bool) -> HeadingUpdateService {
        locMgr.displayHeadingCalibration = should
        return self
    }
    
    func trueHeading(enable: Bool) -> HeadingUpdateService {
        _trueHeading = enable
        if enable{
            locMgr.manager.startUpdatingLocation()
        }else{
            locMgr.manager.stopUpdatingLocation()
        }
        return self
    }
    
    func dismissHeadingCalibrationDisplay() {
        locMgr.manager.dismissHeadingCalibrationDisplay()
    }
    
    func clone() -> HeadingUpdateService {
        let clone = DefaultHeadingUpdateService()
        clone.headingFilter(self.headingFilter)
        clone.headingOrientation(self.headingOrientation)
        clone.displayHeadingCalibration(self.displayHeadingCalibration)
        return clone
    }
}