//
//  HeadingUpdateService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

#if os(iOS)
    
    import Foundation
    import CoreLocation
    import RxSwift
    
    //MARK: HeadingUpdateServiceConfigurable
    public protocol HeadingUpdateServiceConfigurable{
        /**
         Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instp/CLLocationManager/headingFilter)
         
         - parameter degrees: to filter
         
         - returns: self for chaining call
         */
        func headingFilter(degrees:CLLocationDegrees) -> HeadingUpdateService
        /**
         Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instp/CLLocationManager/headingOrientation)
         
         - parameter degrees
         
         - returns: self for chaining call
         */
        func headingOrientation(degrees:CLDeviceOrientation) -> HeadingUpdateService
        /**
         Should display heading calibration during monitoring heading update?
         
         - parameter should: display heading calibration
         
         - returns: self for chaining call
         */
        func displayHeadingCalibration(should:Bool) -> HeadingUpdateService
        /**
         If reports true heading in CLHeading object, refer official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLHeading_Class/index.html#//apple_ref/swift/cl/c:objc(cs)CLHeading) for description
         
         - parameter enable: true heading
         
         - returns: self for chaining call
         */
        func trueHeading(enable:Bool) -> HeadingUpdateService
        /// Current heading filter value
        var headingFilter: CLLocationDegrees{get}
        /// Current heading orientation value
        var headingOrientation: CLDeviceOrientation{get}
        /// Current value of displayHeadingCalibration
        var displayHeadingCalibration: Bool{get}
        /// If currently enabled true heading in CLHeading object
        var trueHeading: Bool{get}
    }
    //MARK: HeadingUpdateService
    public protocol HeadingUpdateService: HeadingUpdateServiceConfigurable{
        /// Observable of current heading update
        var heading: Observable<CLHeading>{get}
        /**
         Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/dismissHeadingCalibrationDisplay)
         */
        func dismissHeadingCalibrationDisplay() -> Void
        /**
         Return a cloned instance of current heading update service
         
         - returns: cloned instance
         */
        func clone() -> HeadingUpdateService
    }
    
    //MARK: DefaultHeadingUpdateService
    class DefaultHeadingUpdateService: HeadingUpdateService {
        private let bridgeClass: LocationManagerBridge.Type
        var locMgr: LocationManagerBridge
        private var _trueHeading: Bool = false
        var trueHeading: Bool{
            get{
                return _trueHeading
            }
        }
        var headingFilter: CLLocationDegrees{
            get{
                return locMgr.headingFilter
            }
        }
        var headingOrientation: CLDeviceOrientation{
            get{
                return locMgr.headingOrientation
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
                        ownerService.locMgr.startUpdatingLocation()
                    }
                    ownerService.locMgr.startUpdatingHeading()
                    return AnonymousDisposable {
                        ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                        if(ownerService.observers.count == 0){
                            ownerService.locMgr.stopUpdatingLocation()
                            ownerService.locMgr.stopUpdatingHeading()
                        }
                        ownerService = nil
                    }
                }
            }
        }
        
        init(bridgeClass: LocationManagerBridge.Type){
            self.bridgeClass = bridgeClass
            locMgr = bridgeClass.init()
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
        
        func headingFilter(degrees: CLLocationDegrees) -> HeadingUpdateService {
            locMgr.headingFilter = degrees
            return self
        }
        
        func headingOrientation(degrees: CLDeviceOrientation) -> HeadingUpdateService {
            locMgr.headingOrientation = degrees
            return self
        }
        
        func displayHeadingCalibration(should: Bool) -> HeadingUpdateService {
            locMgr.displayHeadingCalibration = should
            return self
        }
        
        func trueHeading(enable: Bool) -> HeadingUpdateService {
            _trueHeading = enable
            if enable{
                locMgr.startUpdatingLocation()
            }else{
                locMgr.stopUpdatingLocation()
            }
            return self
        }
        
        func dismissHeadingCalibrationDisplay() {
            locMgr.dismissHeadingCalibrationDisplay()
        }
        
        func clone() -> HeadingUpdateService {
            let clone = DefaultHeadingUpdateService(bridgeClass:bridgeClass)
            clone.headingFilter(self.headingFilter)
            clone.headingOrientation(self.headingOrientation)
            clone.displayHeadingCalibration(self.displayHeadingCalibration)
            return clone
        }
    }
    
#endif