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
}


//MARK: StandardLocationService
public protocol StandardLocationService: StandardLocationServiceConfigurable{
    var locating: Observable<[CLLocation]>{get}
    func clone() -> StandardLocationService
}

//MARK: DefaultStandardLocationService
class DefaultStandardLocationService: StandardLocationService{
    private let locMgrForLocation = Bridge()
    private let locMgrForLocating = Bridge()
    private var locatedObservers = [(id: Int, observer: AnyObserver<CLLocation>)]()
    private var locatingObservers = [(id: Int, observer: AnyObserver<[CLLocation]>)]()
    
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
    
    func clone() -> StandardLocationService {
        let cloned = DefaultStandardLocationService()
        cloned.desiredAccuracy(self.desiredAccuracy)
        cloned.distanceFilter(self.distanceFilter)
        
        return cloned
    }
}
