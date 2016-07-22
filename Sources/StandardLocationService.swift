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
    func distanceFilter(distance: CLLocationDistance) -> StandardLocationService
    func desiredAccuracy(desiredAccuracy: CLLocationAccuracy) -> StandardLocationService
    
    #if os(iOS)
    func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: NSTimeInterval) -> StandardLocationService
    func disallowDeferredLocationUpdates() -> StandardLocationService
    func pausesLocationUpdatesAutomatically(pause : Bool) -> StandardLocationService
    @available(iOS 9.0, *)
    func allowsBackgroundLocationUpdates(allow : Bool) -> StandardLocationService
    func activityType(type: CLActivityType) -> StandardLocationService
    #endif
    
    var distanceFilter: CLLocationDistance {get}
    var desiredAccuracy: CLLocationAccuracy {get}
    
    #if os(iOS)
    var pausesLocationUpdatesAutomatically: Bool {get}
    @available(iOS 9.0, *)
    var allowsBackgroundLocationUpdates: Bool {get}
    var activityType: CLActivityType {get}
    #endif
}


//MARK: StandardLocationService
public protocol StandardLocationService: StandardLocationServiceConfigurable{
    #if os(iOS) || os(OSX)
    /// Observable of current changing location, series of CLLocation objects will be reported, intermittent LocationUnknown error will be ignored, other errors are reported as usual
    var locating: Observable<[CLLocation]>{get}
    #endif
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    /// Observable of current location, only report one CLLocation object and complete, or error if underlying CLLocationManager report error
    var located: Observable<CLLocation>{get}
    #endif
    
    #if os(iOS)
    /// Observable of possible error when calling allowDeferredLocationUpdates method
    var deferredUpdateError: Observable<NSError?>{get}
    /// Observable of pause status
    var isPaused: Observable<Bool>{get}
    #endif
    
    /**
     Return clone object of current standard location service
     
     - returns: cloned standard location service
     */
    func clone() -> StandardLocationService
}

//MARK: DefaultStandardLocationService
class DefaultStandardLocationService: StandardLocationService{
    #if os(iOS) || os(watchOS) || os(tvOS)
    private let locMgrForLocation = Bridge()
    private var locatedObservers = [(id: Int, observer: AnyObserver<CLLocation>)]()
    #endif
    
    #if os(iOS) || os(OSX)
    private let locMgrForLocating = Bridge()
    private var locatingObservers = [(id: Int, observer: AnyObserver<[CLLocation]>)]()
    #endif
    
    #if os(iOS)
    private var deferredUpdateErrorObservers = [(id: Int, observer: AnyObserver<NSError?>)]()
    private var isPausedObservers = [(id: Int, observer: AnyObserver<Bool>)]()
    #endif
    
    var distanceFilter:CLLocationDistance{
        get{
            #if os(OSX)
                return locMgrForLocating.manager.distanceFilter
            #else
                return locMgrForLocation.manager.distanceFilter
            #endif
        }
    }
    var desiredAccuracy: CLLocationAccuracy{
        get{
            #if os(OSX)
                return locMgrForLocating.manager.desiredAccuracy
            #else
                return locMgrForLocation.manager.desiredAccuracy
            #endif
        }
    }
    
    #if os(iOS)
    var pausesLocationUpdatesAutomatically: Bool{
        get{
            return locMgrForLocation.manager.pausesLocationUpdatesAutomatically
        }
    }
    
    @available(iOS 9.0, *)
    var allowsBackgroundLocationUpdates: Bool{
        get{
            return locMgrForLocation.manager.allowsBackgroundLocationUpdates
        }
    }
    var activityType: CLActivityType{
        get{
            return locMgrForLocation.manager.activityType
        }
    }
    #endif
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    var located:Observable<CLLocation> {
        get{
            if self.locMgrForLocation.manager.location != nil{
                return Observable.just(self.locMgrForLocation.manager.location!)
            }else{
                return Observable.create{
                    observer in
                    var ownerService: DefaultStandardLocationService! = self
                    let id = nextId()
                    ownerService.locatedObservers.append((id, observer))
                    if #available(iOS 9.0, *) {
                        ownerService.locMgrForLocation.manager.requestLocation()
                    } else {
                        #if os(iOS)
                            ownerService.locMgrForLocation.manager.startUpdatingLocation()
                        #endif
                    }
                    return AnonymousDisposable{
                        ownerService.locatedObservers.removeAtIndex(ownerService.locatedObservers.indexOf{$0.id == id}!)
                        if(ownerService.locatedObservers.count == 0){
                            ownerService.locMgrForLocation.manager.stopUpdatingLocation()
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
                return AnonymousDisposable{
                    ownerService.locatingObservers.removeAtIndex(ownerService.isPausedObservers.indexOf{$0.id == id}!)
                    ownerService = nil
                }
            }
        }
    }
    
    var deferredUpdateError:Observable<NSError?>{
        get{
            return Observable.create {
                observer in
                var ownerService: DefaultStandardLocationService! = self
                let id = nextId()
                ownerService.deferredUpdateErrorObservers.append((id, observer))
                return AnonymousDisposable{
                    ownerService.deferredUpdateErrorObservers.removeAtIndex(ownerService.deferredUpdateErrorObservers.indexOf{$0.id == id}!)
                    ownerService = nil
                }
            }
        }
    }
    #endif
    
    #if os(iOS) || os(OSX)
    var locating:Observable<[CLLocation]> {
        get{
            return Observable.create {
                observer in
                var ownerService: DefaultStandardLocationService! = self
                let id = nextId()
                ownerService.locatingObservers.append((id, observer))
                //calling this method to start updating location anyway, it's no harm according to the doc
                ownerService.locMgrForLocating.manager.startUpdatingLocation()
                return AnonymousDisposable{
                    ownerService.locatingObservers.removeAtIndex(ownerService.locatingObservers.indexOf{$0.id == id}!)
                    if(ownerService.locatingObservers.count == 0){
                        ownerService.locMgrForLocating.manager.stopUpdatingLocation()
                    }
                    ownerService = nil
                }
            }
        }
    }
    #endif
    
    
    init(){
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
                        self?.locMgrForLocation.manager.stopUpdatingLocation()
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
        
        #if os(iOS) || os(OSX)
            locMgrForLocating.didUpdateLocations = {
                [weak self]
                mgr, locations in
                if let copyOfLocatingObservers = self?.locatingObservers{
                    for (_, observer) in copyOfLocatingObservers{
                        #if os(OSX)
                            //locations is [AnyObject] here in macOS
                            observer.onNext(locations as! [CLLocation])
                        #else
                            observer.onNext(locations)
                        #endif
                    }
                }
            }
            
            locMgrForLocating.didFailWithError = {
                [weak self]
                mgr, err in
                if err.domain == "kCLErrorDomain" && CLError.LocationUnknown.rawValue == err.code{
                    //ignore location update error, since new update event may come
                    return
                }
                if let copyOfLocatingObservers = self?.locatingObservers{
                    for (_, observer) in copyOfLocatingObservers{
                        observer.onError(err)
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
    func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: NSTimeInterval) -> StandardLocationService{
        locMgrForLocating.manager.allowDeferredLocationUpdatesUntilTraveled(distance, timeout: timeout)
        return self
    }
    
    func disallowDeferredLocationUpdates() -> StandardLocationService{
        locMgrForLocating.manager.disallowDeferredLocationUpdates()
        return self
    }
    
    func pausesLocationUpdatesAutomatically(pause: Bool) -> StandardLocationService {
        locMgrForLocation.manager.pausesLocationUpdatesAutomatically = pause
        locMgrForLocating.manager.pausesLocationUpdatesAutomatically = pause
        return self
    }
    
    @available(iOS 9.0, *)
    func allowsBackgroundLocationUpdates(allow: Bool) -> StandardLocationService {
        locMgrForLocation.manager.allowsBackgroundLocationUpdates = allow
        locMgrForLocating.manager.allowsBackgroundLocationUpdates = allow
        return self
    }
    
    func activityType(type: CLActivityType) -> StandardLocationService {
        locMgrForLocation.manager.activityType = type
        locMgrForLocating.manager.activityType = type
        return self
    }
    #endif
    
    func distanceFilter(distance: CLLocationDistance) -> StandardLocationService {
        #if os(iOS) || os(watchOS) || os(tvOS)
            locMgrForLocation.manager.distanceFilter = distance
        #endif
        
        #if os(iOS) || os(OSX)
            locMgrForLocating.manager.distanceFilter = distance
        #endif
        return self
    }
    
    func desiredAccuracy(desiredAccuracy: CLLocationAccuracy) -> StandardLocationService {
        #if os(iOS) || os(watchOS) || os(tvOS)
            locMgrForLocation.manager.distanceFilter = desiredAccuracy
        #endif
        
        #if os(iOS) || os(OSX)
            locMgrForLocating.manager.distanceFilter = desiredAccuracy
        #endif
        return self
    }
    
    func clone() -> StandardLocationService {
        let cloned = DefaultStandardLocationService()
        #if os(iOS)
            cloned.activityType(self.activityType)
            if #available(iOS 9.0, *) {
                cloned.allowsBackgroundLocationUpdates(self.allowsBackgroundLocationUpdates)
            }
            cloned.pausesLocationUpdatesAutomatically(self.pausesLocationUpdatesAutomatically)
        #endif
        
        cloned.desiredAccuracy(self.desiredAccuracy)
        cloned.distanceFilter(self.distanceFilter)
        
        return cloned
    }
}