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
    
    var distanceFilter: CLLocationDistance {get}
    var desiredAccuracy: CLLocationAccuracy {get}
    
    func pausesLocationUpdatesAutomatically(pause : Bool) -> StandardLocationService
    @available(iOS 9.0, *)
    func allowsBackgroundLocationUpdates(allow : Bool) -> StandardLocationService
    func activityType(type: CLActivityType) -> StandardLocationService
    
    
    var pausesLocationUpdatesAutomatically: Bool {get}
    @available(iOS 9.0, *)
    var allowsBackgroundLocationUpdates: Bool{get}
    var activityType: CLActivityType {get}
}


//MARK: StandardLocationService
public protocol StandardLocationService: StandardLocationServiceConfigurable{
    var located: Observable<CLLocation>{get}
    var locating: Observable<[CLLocation]>{get}
    var isPaused: Observable<Bool>{get}
    func clone() -> StandardLocationService
}

//MARK: DefaultStandardLocationService
class DefaultStandardLocationService: StandardLocationService{
    private let locMgrForLocation = Bridge()
    private let locMgrForLocating = Bridge()
    private var locatedObservers = [(id: Int, observer: AnyObserver<CLLocation>)]()
    private var locatingObservers = [(id: Int, observer: AnyObserver<[CLLocation]>)]()
    private var isPausedObservers = [(id: Int, observer: AnyObserver<Bool>)]()
    
    var distanceFilter:CLLocationDistance{
        get{
            return locMgrForLocation.manager.distanceFilter
        }
    }
    var desiredAccuracy: CLLocationAccuracy{
        get{
            return locMgrForLocation.manager.desiredAccuracy
        }
    }
    
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
                        ownerService.locMgrForLocation.manager.startUpdatingLocation()
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
    
    init(){
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
    }
    
    deinit{
        print("StandardLocationService deinit")
    }
    
    func distanceFilter(distance: CLLocationDistance) -> StandardLocationService {
        locMgrForLocation.manager.distanceFilter = distance
        locMgrForLocating.manager.distanceFilter = distance
        return self
    }
    
    func desiredAccuracy(desiredAccuracy: CLLocationAccuracy) -> StandardLocationService {
        locMgrForLocation.manager.desiredAccuracy = desiredAccuracy
        locMgrForLocating.manager.desiredAccuracy = desiredAccuracy
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
    
    func clone() -> StandardLocationService {
        let cloned = DefaultStandardLocationService()
        cloned.activityType(self.activityType)
        if #available(iOS 9.0, *) {
            cloned.allowsBackgroundLocationUpdates(self.allowsBackgroundLocationUpdates)
        }
        cloned.pausesLocationUpdatesAutomatically(self.pausesLocationUpdatesAutomatically)
        
        cloned.desiredAccuracy(self.desiredAccuracy)
        cloned.distanceFilter(self.distanceFilter)
        
        return cloned
    }
}
