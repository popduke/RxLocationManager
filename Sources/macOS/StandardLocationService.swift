//
//  StandardLocationService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
#if os(OSX)
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
    private let locMgrForLocating = Bridge()
    private var locatingObservers = [(id: Int, observer: AnyObserver<[CLLocation]>)]()
    
    var distanceFilter:CLLocationDistance{
        get{
            return locMgrForLocating.manager.distanceFilter
        }
    }
    var desiredAccuracy: CLLocationAccuracy{
        get{
            return locMgrForLocating.manager.desiredAccuracy
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
    
    func distanceFilter(distance: CLLocationDistance) -> StandardLocationService {
        locMgrForLocating.manager.distanceFilter = distance
        return self
    }
    
    func desiredAccuracy(desiredAccuracy: CLLocationAccuracy) -> StandardLocationService {
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
#endif