//
//  RegionMonitoringService.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
#if os(iOS) || os(OSX)
    import Foundation
    import CoreLocation
    import RxSwift
    
    //MARK: RegionMonitoringServiceConfigurable
    public protocol RegionMonitoringServiceConfigurable{
        /**
         Unlike the official [version](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/startMonitoringForRegion:), this method allows you to start monitoring multiple regions at once
         
         - parameter regions: to start monitoring
         
         - returns: self for chaining call
         */
        func startMonitoringForRegions(_ regions: [CLRegion]) -> RegionMonitoringService
        /**
         Unlike the official [version](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/stopMonitoringForRegion:), this method allows you to stop monitoring multiple regions at once
         
         - parameter regions: to stop monitoring
         
         - returns: self for chaining call
         */
        func stopMonitoringForRegions(_ regions: [CLRegion]) -> RegionMonitoringService
        /**
         convenient method to stop all monitored regions at once
         
         - returns: self for chaining call
         */
        func stopMonitoringForAllRegions() -> RegionMonitoringService
        /**
         Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/requestStateForRegion:)
         
         - parameter regions: to request
         
         - returns: self for chaining call
         */
        func requestRegionsState(_ regions:[CLRegion]) -> RegionMonitoringService
        
        #if os(iOS)
        /**
         Refer to official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/startRangingBeaconsInRegion:), this method allows you to start regioning multiple beacons at once
         
         - parameter region: to start regioning
         
         - returns: self for chaining call
         */
        func startRangingBeaconsInRegion(_ region: CLBeaconRegion) -> RegionMonitoringService
        /**
         Refer to official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/stopRangingBeaconsInRegion:)
         
         - parameter region: to stop regioning
         
         - returns: self for chaining call
         */
        func stopRangingBeaconsInRegion(_ region: CLBeaconRegion) -> RegionMonitoringService
        #endif
    }
    //MARK: RegionMonitoringService
    public protocol RegionMonitoringService: RegionMonitoringServiceConfigurable{
        /// Refer description in official [document](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instp/CLLocationManager/maximumRegionMonitoringDistance)
        var maximumRegionMonitoringDistance: CLLocationDistance { get }
        /// Observable of current monitored regions
        var monitoredRegions: Observable<Set<CLRegion>> { get }
        /// Observable of region entering event
        var entering: Observable<CLRegion>{get}
        /// Observable of region exiting event
        var exiting: Observable<CLRegion>{get}
        /// Observable of determined state of requested region
        var determinedRegionState: Observable<(CLRegion, CLRegionState)> {get}
        /// Observable of possible errors during monitoring or ranging, errors won't trigger onError on each Observable, so caller have to manage subscription lifecycle explicitly
        var error: Observable<(CLRegion?, NSError)>{get}
        
        
        #if os(iOS)
        /// Observable of current ranged beacons
        var ranging: Observable<([CLBeacon], CLBeaconRegion)>{get}
        /// Set of currently ranged beacon regions 
        var rangedRegions: Set<CLBeaconRegion> {get}
        #endif
    }
    
    //MARK: DefaultRegionMonitoringService
    class DefaultRegionMonitoringService: RegionMonitoringService{
        let locMgr: CLLocationManagerBridge
    
        fileprivate var enteringObservers = [(id:Int, observer: AnyObserver<CLRegion>)]()
        fileprivate var exitingObservers = [(id:Int, observer: AnyObserver<CLRegion>)]()
        fileprivate var determinedRegionStateObservers = [(id:Int, observer: AnyObserver<(CLRegion, CLRegionState)>)]()
        fileprivate var errorObservers = [(id:Int, observer: AnyObserver<(CLRegion?, NSError)>)]()
        fileprivate var monitoredRegionsObservers = [(id:Int, observer: AnyObserver<Set<CLRegion>>)]()
        
        #if os(iOS)
        fileprivate var rangingObservers = [(id:Int, observer: AnyObserver<([CLBeacon], CLBeaconRegion)>)]()
        #endif
        
        var maximumRegionMonitoringDistance: CLLocationDistance{
            get{
                return locMgr.maximumRegionMonitoringDistance
            }
        }
        
        var entering: Observable<CLRegion>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultRegionMonitoringService! = self
                    let id = nextId()
                    ownerService.enteringObservers.append((id, observer))
                    return Disposables.create {
                        ownerService.enteringObservers.remove(at: ownerService.enteringObservers.index(where: {$0.id == id})!)
                        ownerService = nil
                    }
                }
            }
        }
        
        var exiting: Observable<CLRegion>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultRegionMonitoringService! = self
                    let id = nextId()
                    ownerService.exitingObservers.append((id, observer))
                    return Disposables.create {
                        ownerService.exitingObservers.remove(at: ownerService.exitingObservers.index(where: {$0.id == id})!)
                        ownerService = nil
                    }
                }
            }
        }
        
        var determinedRegionState: Observable<(CLRegion, CLRegionState)>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultRegionMonitoringService! = self
                    let id = nextId()
                    ownerService.determinedRegionStateObservers.append((id, observer))
                    return Disposables.create {
                        ownerService.determinedRegionStateObservers.remove(at: ownerService.determinedRegionStateObservers.index(where: {$0.id == id})!)
                        ownerService = nil
                    }
                }
            }
        }
        
        var error: Observable<(CLRegion?, NSError)>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultRegionMonitoringService! = self
                    let id = nextId()
                    ownerService.errorObservers.append((id, observer))
                    return Disposables.create {
                        ownerService.errorObservers.remove(at: ownerService.errorObservers.index(where: {$0.id == id})!)
                        ownerService = nil
                    }
                }
            }
        }
        
        var monitoredRegions: Observable<Set<CLRegion>>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultRegionMonitoringService! = self
                    let id = nextId()
                    ownerService.monitoredRegionsObservers.append((id, observer))
                    if !ownerService.locMgr.monitoredRegions.isEmpty{
                        observer.onNext(ownerService.locMgr.monitoredRegions)
                    }
                    return Disposables.create {
                        ownerService.monitoredRegionsObservers.remove(at: ownerService.monitoredRegionsObservers.index(where:{$0.id == id})!)
                        ownerService = nil
                    }
                }
            }
        }
        
        #if os(iOS)
        var rangedRegions: Set<CLBeaconRegion> {
            get{
                return locMgr.rangedRegions as! Set<CLBeaconRegion>
            }
        }
        var ranging: Observable<([CLBeacon], CLBeaconRegion)>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultRegionMonitoringService! = self
                    let id = nextId()
                    ownerService.rangingObservers.append((id, observer))
                    return Disposables.create {
                        ownerService.rangingObservers.remove(at: ownerService.rangingObservers.index(where: {$0.id == id})!)
                        ownerService = nil
                    }
                }
            }
        }
        #endif
        
        init(bridgeClass: CLLocationManagerBridge.Type){
            locMgr = bridgeClass.init()
            locMgr.didEnterRegion = {
                [weak self]
                mgr, region in
                if let copyOfEnteringObservers = self?.enteringObservers{
                    for (_, observer) in copyOfEnteringObservers{
                        observer.onNext(region)
                    }
                }
            }
            locMgr.didExitRegion = {
                [weak self]
                mgr, region in
                if let copyOfExitingObservers = self?.exitingObservers{
                    for (_, observer) in copyOfExitingObservers{
                        observer.onNext(region)
                    }
                }
            }
            locMgr.monitoringDidFailForRegion = {
                [weak self]
                mgr, region, error in
                if let copyOfErrorObservers = self?.errorObservers{
                    for (_, observer) in copyOfErrorObservers{
                        observer.onNext((region, error))
                    }
                }
            }
            locMgr.didStartMonitoringForRegion = {
                [weak self]
                mgr, region in
                if let copyOfMonitoredRegionsObservers = self?.monitoredRegionsObservers{
                    for (_, observer) in copyOfMonitoredRegionsObservers{
                        observer.onNext(self!.locMgr.monitoredRegions)
                    }
                }
            }
            locMgr.didDetermineState = {
                [weak self]
                mgr, state, region in
                if let copyOfDeterminedRegionStateObservers = self?.determinedRegionStateObservers{
                    for(_, observer) in copyOfDeterminedRegionStateObservers{
                        observer.onNext((region, state))
                    }
                }
            }
            #if os(iOS)
            locMgr.didRangeBeaconsInRegion = {
                [weak self]
                mgr, beacons, region in
                if let copyOfRangingObservers = self?.rangingObservers{
                    for (_, observer) in copyOfRangingObservers{
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
            #endif
        }
        
        func requestRegionsState(_ regions: [CLRegion]) -> RegionMonitoringService {
            for region in regions{
                locMgr.requestState(for: region)
            }
            return self
        }
        
        func startMonitoringForRegions(_ regions: [CLRegion]) -> RegionMonitoringService {
            for region in regions{
                locMgr.startMonitoring(for: region)
            }
            return self
        }
        
        func stopMonitoringForRegions(_ regions: [CLRegion]) -> RegionMonitoringService {
            for region in regions{
                locMgr.stopMonitoring(for: region)
            }
            
            //Workaround for lacking knowledge about the time when regions actually stop monitored
            let currentMonitoredRegions = locMgr.monitoredRegions.subtracting(regions)
            for (_, observer) in monitoredRegionsObservers{
                observer.onNext(currentMonitoredRegions)
            }
            return self
        }
        
        func stopMonitoringForAllRegions() -> RegionMonitoringService {
            for region in locMgr.monitoredRegions{
                locMgr.stopMonitoring(for: region)
            }
            return self
        }
        
        #if os(iOS)
        func startRangingBeaconsInRegion(_ region: CLBeaconRegion) -> RegionMonitoringService {
            locMgr.startRangingBeacons(in: region)
            return self
        }
        
        func stopRangingBeaconsInRegion(_ region: CLBeaconRegion) -> RegionMonitoringService {
            locMgr.stopRangingBeacons(in: region)
            return self
        }
        #endif
    }
#endif
