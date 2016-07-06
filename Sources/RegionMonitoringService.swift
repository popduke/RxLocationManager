//
//  RegionMonitoringService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift


//MARK: RegionMonitoringServiceConfigurable
public protocol RegionMonitoringServiceConfigurable{
    var monitoredRegions: Set<CLRegion> { get }
    var maximumRegionMonitoringDistance: CLLocationDistance { get }
    func startMonitoringForRegions(regions: [CLRegion]) -> RegionMonitoringService
    func stopMonitoringForRegions(regions: [CLRegion]) -> RegionMonitoringService
    func stopMonitoringForAllRegions() -> RegionMonitoringService
}
//MARK: RegionMonitoringService
public protocol RegionMonitoringService: RegionMonitoringServiceConfigurable{
    var entering: Observable<CLRegion>{get}
    var exiting: Observable<CLRegion>{get}
    var error: Observable<(CLRegion?, NSError)>{get}
}

//MARK: DefaultRegionMonitoringService
class DefaultRegionMonitoringService: RegionMonitoringService{
    private let locMgr: Bridge = Bridge(bridgedManager: CLLocationManager())
    
    private var enteringObservers = [(id:Int, observer: AnyObserver<CLRegion>)]()
    private var exitingObservers = [(id:Int, observer: AnyObserver<CLRegion>)]()
    private var errorObservers = [(id:Int, observer: AnyObserver<(CLRegion?, NSError)>)]()
    var monitoredRegions: Set<CLRegion>{
        get{
            return locMgr.manager.monitoredRegions
        }
    }
    
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
        return self
    }
    
    func stopMonitoringForAllRegions() -> RegionMonitoringService {
        for region in monitoredRegions{
            locMgr.manager.stopMonitoringForRegion(region)
        }
        return self
    }
    
    deinit{
        stopMonitoringForAllRegions()
    }
}
