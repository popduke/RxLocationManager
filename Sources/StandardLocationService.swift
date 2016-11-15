//
//  StandardLocationService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
import Foundation
import CoreLocation
import RxSwift


//MARK: StandardLocationServiceConfigurable
public protocol StandardLocationServiceConfigurable{
    /**
     Set distance filter
     
     - parameter distance
     
     - returns: self for chaining call
     */
    func distanceFilter(_ distance: CLLocationDistance) -> StandardLocationService
    /**
     Set desired accuracy
     
     - parameter desiredAccuracy
     
     - returns: self for chaining call
     */
    func desiredAccuracy(_ desiredAccuracy: CLLocationAccuracy) -> StandardLocationService
    
    #if os(iOS)
    /**
     Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/allowDeferredLocationUpdatesUntilTraveled:timeout:)
     - parameter distance
     - parameter timeout
     
     - returns: self for chaining call
     */
    func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: TimeInterval) -> StandardLocationService
    /**
     Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/disallowDeferredLocationUpdates)
     
     - returns: self for chaining call
     */
    func disallowDeferredLocationUpdates() -> StandardLocationService
    /**
     Set Boolean value to [pausesLocationUpdatesAutomatically](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instp/CLLocationManager/pausesLocationUpdatesAutomatically)
     
     - parameter pause: Boolean value
     
     - returns: self for chaining call
     */
    func pausesLocationUpdatesAutomatically(_ pause : Bool) -> StandardLocationService
    
    
    /**
     Set Boolean value to [allowsBackgroundLocationUpdates](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instp/CLLocationManager/allowsBackgroundLocationUpdates)
     
     - parameter allow: Boolean value
     
     - returns: self for chaining call
     */
    @available(iOS 9.0, *)
    func allowsBackgroundLocationUpdates(_ allow : Bool) -> StandardLocationService
    /**
     Set value to [activityType](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instp/CLLocationManager/activityType)
     
     - parameter type
     
     - returns: self for chaining call
     */
    func activityType(_ type: CLActivityType) -> StandardLocationService
    #endif
    
    /// Current distance filter value
    var distanceFilter: CLLocationDistance {get}
    /// Current desired accuracy value
    var desiredAccuracy: CLLocationAccuracy {get}
    
    #if os(iOS)
    /// Current pausesLocationUpdatesAutomatically value
    var pausesLocationUpdatesAutomatically: Bool {get}
    @available(iOS 9.0, *)
    /// Current allowsBackgroundLocationUpdates
    var allowsBackgroundLocationUpdates: Bool {get}
    /// Current activityType
    var activityType: CLActivityType {get}
    #endif
}


//MARK: StandardLocationService
public protocol StandardLocationService: StandardLocationServiceConfigurable{
    #if os(iOS) || os(OSX) || os(watchOS)
    /// Observable of current changing location, series of CLLocation objects will be reported, intermittent LocationUnknown error will be ignored and not stop subscriptions on this observable, other errors are reported as usual
    @available(watchOS 3.0, *)
    var locating: Observable<[CLLocation]>{get}
    #endif
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    /// Observable of current location, only report one CLLocation object and complete, or error if underlying CLLocationManager reports error
    var located: Observable<CLLocation>{get}
    #endif
    
    #if os(iOS)
    /// Observable of possible error when calling allowDeferredLocationUpdates method
    var deferredUpdateFinished: Observable<NSError?>{get}
    /// Observable of pause status
    var isPaused: Observable<Bool>{get}
    #endif
    
    /**
     Return cloned instance
     
     - returns: cloned standard location service
     */
    func clone() -> StandardLocationService
}

//MARK: DefaultStandardLocationService
class DefaultStandardLocationService: StandardLocationService{
    fileprivate let bridgeClass: CLLocationManagerBridge.Type
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    var locMgrForLocation:CLLocationManagerBridge!
    fileprivate var locatedObservers = [(id: Int, observer: AnyObserver<CLLocation>)]()
    #endif
    
    #if os(iOS) || os(OSX) || os(watchOS)
    var locMgrForLocating:CLLocationManagerBridge!
    fileprivate var locatingObservers = [(id: Int, observer: AnyObserver<[CLLocation]>)]()
    #endif
    
    #if os(iOS)
    fileprivate var deferredUpdateErrorObservers = [(id: Int, observer: AnyObserver<NSError?>)]()
    fileprivate var isPausedObservers = [(id: Int, observer: AnyObserver<Bool>)]()
    #endif
    
    var distanceFilter:CLLocationDistance{
        get{
            #if os(OSX)
                return locMgrForLocating.distanceFilter
            #else
                return locMgrForLocation.distanceFilter
            #endif
        }
    }
    var desiredAccuracy: CLLocationAccuracy{
        get{
            #if os(OSX)
                return locMgrForLocating.desiredAccuracy
            #else
                return locMgrForLocation.desiredAccuracy
            #endif
        }
    }
    
    #if os(iOS)
    var pausesLocationUpdatesAutomatically: Bool{
        get{
            return locMgrForLocating.pausesLocationUpdatesAutomatically
        }
    }
    
    @available(iOS 9.0, *)
    var allowsBackgroundLocationUpdates: Bool{
        get{
            return locMgrForLocating.allowsBackgroundLocationUpdates
        }
    }
    var activityType: CLActivityType{
        get{
            return locMgrForLocating.activityType
        }
    }
    #endif
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    var located:Observable<CLLocation> {
        get{
            if self.locMgrForLocation.location != nil{
                return Observable.just(self.locMgrForLocation.location!)
            }else{
                return Observable.create{
                    observer in
                    var ownerService: DefaultStandardLocationService! = self
                    let id = nextId()
                    ownerService.locatedObservers.append((id, observer))
                    if #available(iOS 9.0, *) {
                        ownerService.locMgrForLocation.requestLocation()
                    } else {
                        #if os(iOS)
                            ownerService.locMgrForLocation.startUpdatingLocation()
                        #endif
                    }
                    return Disposables.create {
                        ownerService.locatedObservers.remove(at: ownerService.locatedObservers.index(where: {$0.id == id})!)
                        if(ownerService.locatedObservers.count == 0){
                            ownerService.locMgrForLocation.stopUpdatingLocation()
                        }
                        ownerService = nil
                    }
                }
            }
        }
    }
    #endif
    
    #if os(iOS)
    var isPaused:Observable<Bool>{
        get{
            return Observable.create {
                observer in
                var ownerService: DefaultStandardLocationService! = self
                let id = nextId()
                ownerService.isPausedObservers.append((id, observer))
                return Disposables.create {
                    ownerService.isPausedObservers.remove(at: ownerService.isPausedObservers.index(where: {$0.id == id})!)
                    ownerService = nil
                }
            }
        }
    }
    
    var deferredUpdateFinished:Observable<NSError?>{
        get{
            return Observable.create {
                observer in
                var ownerService: DefaultStandardLocationService! = self
                let id = nextId()
                ownerService.deferredUpdateErrorObservers.append((id, observer))
                return Disposables.create {
                    ownerService.deferredUpdateErrorObservers.remove(at: ownerService.deferredUpdateErrorObservers.index(where: {$0.id == id})!)
                    ownerService = nil
                }
            }
        }
    }
    #endif
    
    #if os(iOS) || os(OSX) || os(watchOS)
    @available(watchOS 3.0, *)
    var locating:Observable<[CLLocation]> {
        get{
            return Observable.create {
                observer in
                var ownerService: DefaultStandardLocationService! = self
                let id = nextId()
                ownerService.locatingObservers.append((id, observer))
                //calling this method to start updating location anyway, it's no harm according to the doc
                ownerService.locMgrForLocating.startUpdatingLocation()
                return Disposables.create {
                    ownerService.locatingObservers.remove(at: ownerService.locatingObservers.index(where: {$0.id == id})!)
                    if(ownerService.locatingObservers.count == 0){
                        ownerService.locMgrForLocating.stopUpdatingLocation()
                    }
                    ownerService = nil
                }
            }
        }
    }
    #endif
    
    
    init(bridgeClass: CLLocationManagerBridge.Type){
        self.bridgeClass = bridgeClass
        #if os(iOS) || os(watchOS) || os(tvOS)
        locMgrForLocation = bridgeClass.init()
        #endif
        
        #if os(iOS) || os(OSX) || os(watchOS)
            if #available(watchOS 3.0, *) {
                locMgrForLocating = bridgeClass.init()
            }
        #endif
        
        #if os(iOS) || os(watchOS) || os(tvOS)
            locMgrForLocation.didUpdateLocations = {
                [weak self]
                mgr, locations in
                if let copyOfLocatedObservers = self?.locatedObservers{
                    for (_, observer) in copyOfLocatedObservers{
                        observer.onNext(locations.last!)
                        observer.onCompleted()
                    }
                    guard #available(iOS 9.0, *) else {
                        self?.locMgrForLocation.stopUpdatingLocation()
                        return
                    }
                    
                }
            }
            locMgrForLocation.didFailWithError = {
                [weak self]
                mgr, err in
                if let copyOfLocatedObservers = self?.locatedObservers{
                    for (_, observer) in copyOfLocatedObservers{
                        observer.onError(err)
                    }
                }
            }
        #endif
        
        #if os(iOS) || os(OSX) || os(watchOS)
            if #available(watchOS 3.0, *){
                locMgrForLocating.didUpdateLocations = {
                    [weak self]
                    mgr, locations in
                    if let copyOfLocatingObservers = self?.locatingObservers{
                        for (_, observer) in copyOfLocatingObservers{
                            observer.onNext(locations)
                        }
                    }
                }
                
                locMgrForLocating.didFailWithError = {
                    [weak self]
                    mgr, err in
                    if err.domain == "kCLErrorDomain" && CLError.locationUnknown.rawValue == err.code{
                        //ignore location update error, since new update event may come
                        return
                    }
                    if let copyOfLocatingObservers = self?.locatingObservers{
                        for (_, observer) in copyOfLocatingObservers{
                            observer.onError(err)
                        }
                    }
                }
            }
        #endif
        
        
        #if os(iOS)
            locMgrForLocating.didFinishDeferredUpdatesWithError = {
                [weak self]
                mgr, error in
                if let copyOfdeferredUpdateErrorObservers = self?.deferredUpdateErrorObservers{
                    for (_, observer) in copyOfdeferredUpdateErrorObservers{
                        observer.onNext(error)
                    }
                }
            }
            
            locMgrForLocating.didPausedUpdate = {
                [weak self]
                mgr in
                if let copyOfIsPausedObservers = self?.isPausedObservers{
                    for(_, observer) in copyOfIsPausedObservers{
                        observer.onNext(true)
                    }
                }
            }
            locMgrForLocating.didResumeUpdate = {
                [weak self]
                mgr in
                if let copyOfIsPausedObservers = self?.isPausedObservers{
                    for(_, observer) in copyOfIsPausedObservers{
                        observer.onNext(false)
                    }
                }
            }
        #endif
    }
    
    #if os(iOS)
    func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: TimeInterval) -> StandardLocationService{
        locMgrForLocating.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
        return self
    }
    
    func disallowDeferredLocationUpdates() -> StandardLocationService{
        locMgrForLocating.disallowDeferredLocationUpdates()
        return self
    }
    
    func pausesLocationUpdatesAutomatically(_ pause: Bool) -> StandardLocationService {
        locMgrForLocating.pausesLocationUpdatesAutomatically = pause
        return self
    }
    
    @available(iOS 9.0, *)
    func allowsBackgroundLocationUpdates(_ allow: Bool) -> StandardLocationService {
        locMgrForLocating.allowsBackgroundLocationUpdates = allow
        return self
    }
    
    func activityType(_ type: CLActivityType) -> StandardLocationService {
        locMgrForLocating.activityType = type
        return self
    }
    #endif
    
    func distanceFilter(_ distance: CLLocationDistance) -> StandardLocationService {
        #if os(iOS) || os(watchOS) || os(tvOS)
            locMgrForLocation.distanceFilter = distance
        #endif
        
        #if os(iOS) || os(OSX)
            locMgrForLocating.distanceFilter = distance
        #endif
        return self
    }
    
    func desiredAccuracy(_ desiredAccuracy: CLLocationAccuracy) -> StandardLocationService {
        #if os(iOS) || os(watchOS) || os(tvOS)
            locMgrForLocation.desiredAccuracy = desiredAccuracy
        #endif
        
        #if os(iOS) || os(OSX)
            locMgrForLocating.desiredAccuracy = desiredAccuracy
        #endif
        return self
    }
    
    func clone() -> StandardLocationService {
        let cloned = DefaultStandardLocationService(bridgeClass: bridgeClass)
        #if os(iOS)
            _ = cloned.activityType(self.activityType)
            if #available(iOS 9.0, *) {
                _ = cloned.allowsBackgroundLocationUpdates(self.allowsBackgroundLocationUpdates)
            }
            _ = cloned.pausesLocationUpdatesAutomatically(self.pausesLocationUpdatesAutomatically)
        #endif
        
        _ = cloned.desiredAccuracy(self.desiredAccuracy)
        _ = cloned.distanceFilter(self.distanceFilter)
        
        return cloned
    }
}
