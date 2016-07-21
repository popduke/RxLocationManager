//
//  RegionMonitoringService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
#if os(iOS)
    import Foundation
    import CoreLocation
    import RxSwift
    
    //MARK: RegionMonitoringServiceConfigurable
    public protocol RegionMonitoringServiceConfigurable{
        var maximumRegionMonitoringDistance: CLLocationDistance { get }
        func startMonitoringForRegions(regions: [CLRegion]) -> RegionMonitoringService
        func stopMonitoringForRegions(regions: [CLRegion]) -> RegionMonitoringService
        func stopMonitoringForAllRegions() -> RegionMonitoringService
        func requestRegionsState(regions:[CLRegion]) -> RegionMonitoringService
    }
    //MARK: RegionMonitoringService
    public protocol RegionMonitoringService: RegionMonitoringServiceConfigurable{
        var monitoredRegions: Observable<Set<CLRegion>> { get }
        var entering: Observable<CLRegion>{get}
        var exiting: Observable<CLRegion>{get}
        var determinedRegionState: Observable<(CLRegion, CLRegionState)> {get}
        var error: Observable<(CLRegion?, NSError)>{get}
    }
    
    //MARK: DefaultRegionMonitoringService
    class DefaultRegionMonitoringService: RegionMonitoringService{
        private let locMgr: Bridge = Bridge()
        
        private var enteringObservers = [(id:Int, observer: AnyObserver<CLRegion>)]()
        private var exitingObservers = [(id:Int, observer: AnyObserver<CLRegion>)]()
        private var determinedRegionStateObservers = [(id:Int, observer: AnyObserver<(CLRegion, CLRegionState)>)]()
        private var errorObservers = [(id:Int, observer: AnyObserver<(CLRegion?, NSError)>)]()
        private var monitoredRegionsObservers = [(id:Int, observer: AnyObserver<Set<CLRegion>>)]()
        
        var maximumRegionMonitoringDistance: CLLocationDistance{
            get{
                return locMgr.manager.maximumRegionMonitoringDistance
            }
        }
        
        var entering: Observable<CLRegion>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultRegionMonitoringService! = self
                    let id = nextId()
                    ownerService.enteringObservers.append((id, observer))
                    return AnonymousDisposable{
                        ownerService.enteringObservers.removeAtIndex(ownerService.enteringObservers.indexOf{$0.id == id}!)
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
                    return AnonymousDisposable{
                        ownerService.exitingObservers.removeAtIndex(ownerService.exitingObservers.indexOf{$0.id == id}!)
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
                    return AnonymousDisposable{
                        ownerService.determinedRegionStateObservers.removeAtIndex(ownerService.determinedRegionStateObservers.indexOf{$0.id == id}!)
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
                    return AnonymousDisposable{
                        ownerService.errorObservers.removeAtIndex(ownerService.errorObservers.indexOf{$0.id == id}!)
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
                    if !ownerService.locMgr.manager.monitoredRegions.isEmpty{
                        observer.onNext(ownerService.locMgr.manager.monitoredRegions)
                    }
                    return AnonymousDisposable{
                        ownerService.monitoredRegionsObservers.removeAtIndex(ownerService.monitoredRegionsObservers.indexOf{$0.id == id}!)
                        ownerService = nil
                    }
                }
            }
        }
        
        init(){
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
                        observer.onNext(self!.locMgr.manager.monitoredRegions)
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
        }
        
        func requestRegionsState(regions: [CLRegion]) -> RegionMonitoringService {
            for region in regions{
                locMgr.manager.requestStateForRegion(region)
            }
            return self
        }
        
        func startMonitoringForRegions(regions: [CLRegion]) -> RegionMonitoringService {
            for region in regions{
                locMgr.manager.startMonitoringForRegion(region)
            }
            return self
        }
        
        func stopMonitoringForRegions(regions: [CLRegion]) -> RegionMonitoringService {
            for region in regions{
                locMgr.manager.stopMonitoringForRegion(region)
            }
            
            //Workaround for lacking knowledge about the time when regions actually stop monitored
            let currentMonitoredRegions = locMgr.manager.monitoredRegions.subtract(regions)
            for (_, observer) in monitoredRegionsObservers{
                observer.onNext(currentMonitoredRegions)
            }
            return self
        }
        
        func stopMonitoringForAllRegions() -> RegionMonitoringService {
            for region in locMgr.manager.monitoredRegions{
                locMgr.manager.stopMonitoringForRegion(region)
            }
            return self
        }
    }
#endif
