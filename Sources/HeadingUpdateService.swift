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
        func headingFilter(_ degrees:CLLocationDegrees) -> HeadingUpdateService
        /**
         Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instp/CLLocationManager/headingOrientation)
         
         - parameter degrees
         
         - returns: self for chaining call
         */
        func headingOrientation(_ degrees:CLDeviceOrientation) -> HeadingUpdateService
        /**
         Should display heading calibration during monitoring heading update?
         
         - parameter should: display heading calibration
         
         - returns: self for chaining call
         */
        func displayHeadingCalibration(_ should:Bool) -> HeadingUpdateService
        /// Current heading filter value
        var headingFilter: CLLocationDegrees{get}
        /// Current heading orientation value
        var headingOrientation: CLDeviceOrientation{get}
        /// Current value of displayHeadingCalibration
        var displayHeadingCalibration: Bool{get}
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
         Start generating true heading with the specified parameters to start location updating
         
         - parameter withParams: setting distance filter and desired accuracy for the location update
         */
        func startTrueHeading(_ withParams: (distanceFilter:CLLocationDistance, desiredAccuracy:CLLocationAccuracy)?)
        /**
         Stop generating true heading
         */
        func stopTrueHeading()
        /**
         Return a cloned instance of current heading update service
         
         - returns: cloned instance
         */
        func clone() -> HeadingUpdateService
    }
    
    //MARK: DefaultHeadingUpdateService
    class DefaultHeadingUpdateService: HeadingUpdateService {
        fileprivate let bridgeClass: CLLocationManagerBridge.Type
        var locMgr: CLLocationManagerBridge
        fileprivate var trueHeadingParams: (distanceFilter:CLLocationDistance, desiredAccuracy:CLLocationAccuracy)?

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
                    if ownerService.trueHeadingParams != nil{
                        ownerService.locMgr.distanceFilter = ownerService.trueHeadingParams!.distanceFilter
                        ownerService.locMgr.desiredAccuracy = ownerService.trueHeadingParams!.desiredAccuracy
                        ownerService.locMgr.startUpdatingLocation()
                    }
                    ownerService.locMgr.startUpdatingHeading()
                    return Disposables.create {
                        ownerService.observers.remove(at: ownerService.observers.index(where: {$0.id == id})!)
                        if(ownerService.observers.count == 0){
                            ownerService.locMgr.stopUpdatingLocation()
                            ownerService.locMgr.stopUpdatingHeading()
                        }
                        ownerService = nil
                    }
                }
            }
        }
        
        init(bridgeClass: CLLocationManagerBridge.Type){
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
        
        func headingFilter(_ degrees: CLLocationDegrees) -> HeadingUpdateService {
            locMgr.headingFilter = degrees
            return self
        }
        
        func headingOrientation(_ degrees: CLDeviceOrientation) -> HeadingUpdateService {
            locMgr.headingOrientation = degrees
            return self
        }
        
        func displayHeadingCalibration(_ should: Bool) -> HeadingUpdateService {
            locMgr.displayHeadingCalibration = should
            return self
        }
        
        func startTrueHeading(_ withParams: (distanceFilter: CLLocationDistance, desiredAccuracy: CLLocationAccuracy)?) {
            if withParams == nil{
                trueHeadingParams = (1000, kCLLocationAccuracyKilometer)
            }else{
                trueHeadingParams = withParams
            }
            locMgr.distanceFilter = trueHeadingParams!.distanceFilter
            locMgr.desiredAccuracy = trueHeadingParams!.desiredAccuracy
            locMgr.startUpdatingLocation()
            
        }
        
        func stopTrueHeading() {
            locMgr.stopUpdatingLocation()
        }
        
        func dismissHeadingCalibrationDisplay() {
            locMgr.dismissHeadingCalibrationDisplay()
        }
        
        func clone() -> HeadingUpdateService {
            let clone = DefaultHeadingUpdateService(bridgeClass:bridgeClass)
            _ = clone.headingFilter(self.headingFilter)
            _ = clone.headingOrientation(self.headingOrientation)
            _ = clone.displayHeadingCalibration(self.displayHeadingCalibration)
            return clone
        }
    }
    
#endif
