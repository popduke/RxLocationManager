//
//  StandardLocationService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
#if os(tvOS)
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
        var located: Observable<CLLocation>{get}
        func clone() -> StandardLocationService
    }
    
    //MARK: DefaultStandardLocationService
    class DefaultStandardLocationService: StandardLocationService{
        private let locMgrForLocation = Bridge()
        private var locatedObservers = [(id: Int, observer: AnyObserver<CLLocation>)]()
        
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
        }
        
        func distanceFilter(distance: CLLocationDistance) -> StandardLocationService {
            locMgrForLocation.manager.distanceFilter = distance
            return self
        }
        
        func desiredAccuracy(desiredAccuracy: CLLocationAccuracy) -> StandardLocationService {
            locMgrForLocation.manager.desiredAccuracy = desiredAccuracy
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
