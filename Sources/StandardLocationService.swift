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
    func pausesLocationUpdatesAutomatically(pause : Bool) -> StandardLocationService
    @available(iOSApplicationExtension 9.0, *)
    func allowsBackgroundLocationUpdates(allow : Bool) -> StandardLocationService
    func activityType(type: CLActivityType) -> StandardLocationService
    
    var distanceFilter: CLLocationDistance {get}
    var desiredAccuracy: CLLocationAccuracy {get}
    var pausesLocationUpdatesAutomatically: Bool {get}
    @available(iOSApplicationExtension 9.0, *)
    var allowsBackgroundLocationUpdates: Bool{get}
    var activityType: CLActivityType {get}
}

//MARK: StandardLocationService
public protocol StandardLocationService: StandardLocationServiceConfigurable{
    @available(iOSApplicationExtension 9.0, *)
    var located: Observable<CLLocation>{get}
    var locating: Observable<[CLLocation]>{get}
    var isPaused: Observable<Bool>{get}
    func clone() -> StandardLocationService
}

//MARK: DefaultStandardLocationService
class DefaultStandardLocationService: StandardLocationService{
    private let locMgrForLocation = Bridge(bridgedManager: CLLocationManager())
    private let locMgrForLocating = Bridge(bridgedManager: CLLocationManager())
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
    @available(iOSApplicationExtension 9.0, *)
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
    
    @available(iOSApplicationExtension 9.0, *)
    var located:Observable<CLLocation> {
        get{
            return Observable.create{
                observer in
                var ownerService: DefaultStandardLocationService! = self
                let id = nextId()
                ownerService.locatedObservers.append((id, observer))
                ownerService.locMgrForLocation.manager.requestLocation()
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
    
    @available(iOSApplicationExtension 9.0, *)
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
        if #available(iOSApplicationExtension 9.0, *) {
            cloned.allowsBackgroundLocationUpdates(self.allowsBackgroundLocationUpdates)
        }
        cloned.desiredAccuracy(self.desiredAccuracy)
        cloned.distanceFilter(self.distanceFilter)
        cloned.pausesLocationUpdatesAutomatically(self.pausesLocationUpdatesAutomatically)
        return cloned
    }
}