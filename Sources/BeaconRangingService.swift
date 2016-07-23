//
//  BeaconRangingService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

#if os(iOS)
    import Foundation
    import CoreLocation
    import RxSwift
    
    //MARK: BeaconRangingServiceConfigurable
    public protocol BeaconRangingServiceConfigurable{
        /**
         Unlike the official [version](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/startRangingBeaconsInRegion:), this method allows you to start regioning multiple beacons at once
         
         - parameter regions: to start regioning
         
         - returns: self for chaining call
         */
        func startRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService
        /**
         Unlike the official [version](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/stopRangingBeaconsInRegion:), this method allows you to stop regioning multiple beacons at once
         
         - parameter regions: to stop regioning
         
         - returns: self for chaining call
         */
        func stopRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService
        /**
         Convenient method to stop all regioned beacons at once
         
         - returns: self for chaining call
         */
        func stopRangingBeaconsInAllRegions() -> BeaconRangingService
        /**
         Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/requestStateForRegion:)
         
         - parameter regions: to request
         
         - returns: self for chaining call
         */
        func requestRegionsState(regions:[CLBeaconRegion]) -> BeaconRangingService
    }
    //MARK: BeaconRangingService
    public protocol BeaconRangingService: BeaconRangingServiceConfigurable{
        /// Observable of current ranged beacons
        var ranging: Observable<([CLBeacon], CLBeaconRegion)>{get}
        /// Observable of possible error during regioning, errors won't trigger onError on each Observable, so caller have to manage subscription lifecycle explicitly
        var rangingError: Observable<(CLBeaconRegion, NSError)>{get}
        /// Observable of determined state of requested region
        var determinedRegionState: Observable<(CLBeaconRegion, CLRegionState)> {get}
        /// Observable of currently the set of regions being tracked using ranging
        var rangedRegions: Set<CLRegion> {get}
    }
    //MARK: DefaultBeaconRagningService
    class DefaultBeaconRangingService: BeaconRangingService{
        private let locMgr: Bridge = Bridge()
        
        private var observers = [(id:Int, observer: AnyObserver<([CLBeacon], CLBeaconRegion)>)]()
        private var errorObservers = [(id:Int, observer: AnyObserver<(CLBeaconRegion, NSError)>)]()
        private var determinedRegionStateObservers = [(id:Int, observer: AnyObserver<(CLBeaconRegion, CLRegionState)>)]()
        
        var rangedRegions: Set<CLRegion> {
            get{
                return locMgr.manager.rangedRegions
            }
        }
        var ranging: Observable<([CLBeacon], CLBeaconRegion)>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultBeaconRangingService! = self
                    let id = nextId()
                    ownerService.observers.append((id, observer))
                    return AnonymousDisposable{
                        ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                        ownerService = nil
                    }
                }
            }
        }
        
        var determinedRegionState: Observable<(CLBeaconRegion, CLRegionState)>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultBeaconRangingService! = self
                    let id = nextId()
                    ownerService.determinedRegionStateObservers.append((id, observer))
                    return AnonymousDisposable{
                        ownerService.determinedRegionStateObservers.removeAtIndex(ownerService.determinedRegionStateObservers.indexOf{$0.id == id}!)
                        ownerService = nil
                    }
                }
            }
        }
        
        var rangingError: Observable<(CLBeaconRegion, NSError)>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultBeaconRangingService! = self
                    let id = nextId()
                    ownerService.errorObservers.append((id, observer))
                    return AnonymousDisposable{
                        ownerService.errorObservers.removeAtIndex(ownerService.errorObservers.indexOf{$0.id == id}!)
                        ownerService = nil
                    }
                }
            }
        }
        
        init(){
            locMgr.didRangeBeaconsInRegion = {
                [weak self]
                mgr, beacons, region in
                if let copyOfObservers = self?.observers{
                    for (_, observer) in copyOfObservers{
                        observer.onNext((beacons, region))
                    }
                }
            }
            
            locMgr.rangingBeaconsDidFailForRegion = {
                [weak self]
                mgr, region, error in
                if let copyOfErrorObservers = self?.errorObservers{
                    for (_, observer) in copyOfErrorObservers{
                        observer.onNext((region, error))
                    }
                }
            }
            
            locMgr.didDetermineState = {
                [weak self]
                mgr, state, region in
                if let copyOfDeterminedRegionStateObservers = self?.determinedRegionStateObservers{
                    for(_, observer) in copyOfDeterminedRegionStateObservers{
                        observer.onNext((region as! CLBeaconRegion, state))
                    }
                }
            }
        }
        
        func startRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService {
            for region in regions{
                locMgr.manager.startRangingBeaconsInRegion(region)
            }
            return self
        }
        
        func stopRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService {
            for region in regions{
                locMgr.manager.stopRangingBeaconsInRegion(region)
            }
            return self
        }
        
        func stopRangingBeaconsInAllRegions() -> BeaconRangingService {
            for region in rangedRegions as! Set<CLBeaconRegion>{
                locMgr.manager.stopRangingBeaconsInRegion(region)
            }
            return self
        }
        
        func requestRegionsState(regions: [CLBeaconRegion]) -> BeaconRangingService {
            for region in regions{
                locMgr.manager.requestStateForRegion(region)
            }
            return self
        }
    }
#endif

