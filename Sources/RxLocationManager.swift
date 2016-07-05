//
//  RxLocationManager.swift
//  PaperChat
//
//  Created by HaoYu on 16/6/14.
//  Copyright © 2016年 HaoYu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

private var id = -1
private func nextId() -> Int{
    id += 1
    return id
}
//MARK: StandardLocationServiceConfigurable
public protocol StandardLocationServiceConfigurable{
    func distanceFilter(distance: CLLocationDistance) -> StandardLocationService
    func desiredAccuracy(desiredAccuracy: CLLocationAccuracy) -> StandardLocationService
    func pausesLocationUpdatesAutomatically(pause : Bool) -> StandardLocationService
    func allowsBackgroundLocationUpdates(allow : Bool) -> StandardLocationService
    func activityType(type: CLActivityType) -> StandardLocationService
    
    var distanceFilter: CLLocationDistance {get}
    var desiredAccuracy: CLLocationAccuracy {get}
    var pausesLocationUpdatesAutomatically: Bool {get}
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
//MARK: SignificantLocationUpdateService
public protocol SignificantLocationUpdateService{
    var locating: Observable<[CLLocation]> {get}
}
//MARK: HeadingUpdateServiceConfigurable
public protocol HeadingUpdateServiceConfigurable{
    func headingFilter(degrees:CLLocationDegrees) -> HeadingUpdateService
    func headingOrientation(degrees:CLDeviceOrientation) -> HeadingUpdateService
    func displayHeadingCalibration(should:Bool) -> HeadingUpdateService
    var headingFilter: CLLocationDegrees{get}
    var headingOrientation: CLDeviceOrientation{get}
    var displayHeadingCalibration: Bool{get}
}
//MARK: HeadingUpdateService
public protocol HeadingUpdateService: HeadingUpdateServiceConfigurable{
    var heading: Observable<CLHeading>{get}
    func dismissHeadingCalibrationDisplay() -> Void
    func clone() -> HeadingUpdateService
}
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
//MARK: BeaconRangingServiceConfigurable
public protocol BeaconRangingServiceConfigurable{
    var rangedRegions: Set<CLRegion> {get}
    func startRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService
    func stopRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService
    func stopRangingBeaconsInAllRegions() -> BeaconRangingService
}
//MARK: BeaconRangingService
public protocol BeaconRangingService: BeaconRangingServiceConfigurable{
    var ranging: Observable<([CLBeacon], CLBeaconRegion)>{get}
    var rangingError: Observable<(CLBeaconRegion, NSError)>{get}
}
//MARK: MonitoringVisitsService
public protocol MonitoringVisitsService{
    var visiting: Observable<CLVisit>{get}
}

//MARK: Bridge
class Bridge:NSObject, CLLocationManagerDelegate{
    let manager:CLLocationManager
    var didFailWithError: ((CLLocationManager, NSError) -> Void)?
    var didChangeAuthorizationStatus: ((CLLocationManager, CLAuthorizationStatus)->Void)?
    var didUpdateLocations: ((CLLocationManager, [CLLocation]) -> Void)?
    var didUpdateHeading: ((CLLocationManager, CLHeading) -> Void)?
    var displayHeadingCalibration:Bool = false
    var didEnterRegion: ((CLLocationManager, CLRegion) -> Void)?
    var didExitRegion: ((CLLocationManager, CLRegion) -> Void)?
    var monitoringDidFailForRegion: ((CLLocationManager, CLRegion?, NSError) -> Void)?
    var didRangeBeaconsInRegion:((CLLocationManager, [CLBeacon], CLBeaconRegion) -> Void)?
    var rangingBeaconsDidFailForRegion:((CLLocationManager, CLBeaconRegion, NSError) -> Void)?
    var didVisit:((CLLocationManager, CLVisit) -> Void)?
    var didPausedUpdate:((CLLocationManager) -> Void)?
    var didResumeUpdate:((CLLocationManager) -> Void)?
    
    init(bridgedManager:CLLocationManager){
        manager = bridgedManager
        super.init()
        manager.delegate = self
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        didFailWithError?(manager, error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations?(manager, locations)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        didChangeAuthorizationStatus?(manager, status)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        didUpdateHeading?(manager, newHeading)
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return displayHeadingCalibration
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
         didEnterRegion?(manager, region)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
         didExitRegion?(manager, region)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        monitoringDidFailForRegion?(manager, region, error)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        didRangeBeaconsInRegion?(manager, beacons, region)
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError){
        rangingBeaconsDidFailForRegion?(manager, region, error)
    }
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        didVisit?(manager, visit)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        didPausedUpdate?(manager)
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        didResumeUpdate?(manager)
    }
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
        cloned.allowsBackgroundLocationUpdates(self.allowsBackgroundLocationUpdates)
        cloned.desiredAccuracy(self.desiredAccuracy)
        cloned.distanceFilter(self.distanceFilter)
        cloned.pausesLocationUpdatesAutomatically(self.pausesLocationUpdatesAutomatically)
        return cloned
    }
}
//MARK: DefaultSignificantLocationUpdateService
class DefaultSignificantLocationUpdateService: SignificantLocationUpdateService{
    private let locMgr = Bridge(bridgedManager: CLLocationManager())
    private var observers = [(id: Int, AnyObserver<[CLLocation]>)]()
    var locating: Observable<[CLLocation]>{
        get{
            return Observable.create {
                observer in
                var ownerService: DefaultSignificantLocationUpdateService! = self
                let id = nextId()
                ownerService.observers.append((id, observer))
                ownerService.locMgr.manager.startMonitoringSignificantLocationChanges()
                return AnonymousDisposable {
                    ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                    if(ownerService.observers.count == 0){
                        ownerService.locMgr.manager.stopMonitoringSignificantLocationChanges()
                    }
                    ownerService = nil
                }
            }
        }
    }
    
    init(){
        locMgr.didUpdateLocations = {
            [weak self]
            mgr, locations in
            if let copyOfObservers = self?.observers{
                for (_,observer) in copyOfObservers{
                    observer.onNext(locations)
                }
            }
        }
        locMgr.didFailWithError = {
            [weak self]
            mgr, err in
            if let copyOfObservers = self?.observers{
                for (_,observer) in copyOfObservers{
                    observer.onError(err)
                }
            }
        }
    }
}
//MARK: DefaultHeadingUpdateService
class DefaultHeadingUpdateService: HeadingUpdateService {
    private let locMgr: Bridge = Bridge(bridgedManager: CLLocationManager())
    
    var headingFilter: CLLocationDegrees{
        get{
            return locMgr.manager.headingFilter
        }
    }
    var headingOrientation: CLDeviceOrientation{
        get{
            return locMgr.manager.headingOrientation
        }
    }
    var displayHeadingCalibration: Bool{
        get{
            return locMgr.displayHeadingCalibration
        }
    }
    
    var observers = [(id: Int, observer: AnyObserver<CLHeading>)]()
    var heading : Observable<CLHeading>{
        get{
            return Observable.create {
                observer in
                var ownerService: DefaultHeadingUpdateService! = self
                let id = nextId()
                ownerService.observers.append((id, observer))
                ownerService.locMgr.manager.startUpdatingHeading()
                return AnonymousDisposable {
                    ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                    if(ownerService.observers.count == 0){
                        ownerService.locMgr.manager.stopUpdatingLocation()
                    }
                    ownerService = nil
                }
            }
        }
    }
    
    init(){
        locMgr.didUpdateHeading = {
            [weak self]
            mgr, heading in
            if let copyOfObservers = self?.observers{
                for (_, observer) in copyOfObservers{
                    observer.onNext(heading)
                }
            }
        }
        locMgr.didFailWithError = {
            [weak self]
            mgr, err in
            if let copyOfObservers = self?.observers{
                for (_, observer) in copyOfObservers{
                    observer.onError(err)
                }
            }
        }
    }
    
    deinit{
        print("HeadingUpdateService deinit")
    }
    
    func headingFilter(degrees: CLLocationDegrees) -> HeadingUpdateService {
        locMgr.manager.headingFilter = degrees
        return self
    }
    
    func headingOrientation(degrees: CLDeviceOrientation) -> HeadingUpdateService {
        locMgr.manager.headingOrientation = degrees
        return self
    }
    
    func displayHeadingCalibration(should: Bool) -> HeadingUpdateService {
        locMgr.displayHeadingCalibration = should
        return self
    }
    
    func dismissHeadingCalibrationDisplay() {
        locMgr.manager.dismissHeadingCalibrationDisplay()
    }
    
    func clone() -> HeadingUpdateService {
        let clone = DefaultHeadingUpdateService()
        clone.headingFilter(self.headingFilter)
        clone.headingOrientation(self.headingOrientation)
        clone.displayHeadingCalibration(self.displayHeadingCalibration)
        return clone
    }
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

//MARK: DefaultBeaconRagningService
class DefaultBeaconRangingService: BeaconRangingService{
    private let locMgr: Bridge = Bridge(bridgedManager: CLLocationManager())
    
    private var observers = [(id:Int, observer: AnyObserver<([CLBeacon], CLBeaconRegion)>)]()
    private var errorObservers = [(id:Int, observer: AnyObserver<(CLBeaconRegion, NSError)>)]()
    
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
    
    deinit{
        stopRangingBeaconsInAllRegions()
    }
}

//MARK: DefaultMonitoringVisitsService
class DefaultMonitoringVisitsService: MonitoringVisitsService{
    private let locMgr: Bridge = Bridge(bridgedManager: CLLocationManager())
    private var observers = [(id:Int, observer: AnyObserver<CLVisit>)]()
    
    var visiting: Observable<CLVisit>{
        get{
            return Observable.create{
                observer in
                var ownerService:DefaultMonitoringVisitsService! = self
                let id = nextId()
                ownerService.observers.append((id, observer))
                ownerService.locMgr.manager.startMonitoringVisits()
                return AnonymousDisposable{
                    ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                    if ownerService.observers.count == 0{
                        ownerService.locMgr.manager.stopMonitoringVisits()
                    }
                    ownerService = nil
                }
            }
        }
    }
    
    init(){
        locMgr.didVisit = {
            [weak self]
            mgr, visit in
            if let copyOfObservers = self?.observers{
                for (_, observer) in copyOfObservers{
                    observer.onNext(visit)
                }
            }
        }
    }
}
//MARK: RxLocationManager
public class RxLocationManager{
    private static var defaultLocationMgr: Bridge = {
        let locMgr = Bridge(bridgedManager: CLLocationManager())
        locMgr.didChangeAuthorizationStatus = {
            clLocMgr, status in
            authorizationStatusSink.onNext(status)
            enabledSink.onNext(CLLocationManager.locationServicesEnabled())
        }
        return locMgr
    }()
    
    private static var enabledSink:ReplaySubject<Bool> = {
        let replaySubject:ReplaySubject<Bool> = ReplaySubject.create(bufferSize: 1)
        replaySubject.onNext(CLLocationManager.locationServicesEnabled())
        //Force initialize defaultLocationMgr, since it's always lazy
        defaultLocationMgr = defaultLocationMgr
        return replaySubject
    }()
    
    public static var enabled:Observable<Bool>{
        get{
            return enabledSink.distinctUntilChanged()
        }
    }
    
    private static var authorizationStatusSink:ReplaySubject<CLAuthorizationStatus> = {
        let replaySubject:ReplaySubject<CLAuthorizationStatus> = ReplaySubject.create(bufferSize: 1)
        replaySubject.onNext(CLLocationManager.authorizationStatus())
        //Force initialize defaultLocationMgr, since it's always lazy
        defaultLocationMgr = defaultLocationMgr
        return replaySubject
    }()
    
    public static var authorizationStatus: Observable<CLAuthorizationStatus>{
        get{
            return authorizationStatusSink.distinctUntilChanged()
        }
    }
    
    public static func requestWhenInUseAuthorization(){
        defaultLocationMgr.manager.requestWhenInUseAuthorization()
    }
    
    public static func requestAlwaysAuthorization(){
        defaultLocationMgr.manager.requestAlwaysAuthorization()
    }
    
    public static let deferredLocationUpdatesAvailable = CLLocationManager.deferredLocationUpdatesAvailable()
    
    public static let headingAvailable = CLLocationManager.headingAvailable()
    
    public static let isRangingAvailable = CLLocationManager.isRangingAvailable()
    
    public static let significantLocationChangeMonitoringAvailable = CLLocationManager.significantLocationChangeMonitoringAvailable()
    
    public static let Standard: StandardLocationService = DefaultStandardLocationService()
    
    public static let SignificantLocation: SignificantLocationUpdateService = DefaultSignificantLocationUpdateService()
    
    public static let HeadingUpdate: HeadingUpdateService = DefaultHeadingUpdateService()
    
    public static let RegionMonitoring: RegionMonitoringService = DefaultRegionMonitoringService()
    
    public static let VisitMonitoring: MonitoringVisitsService = DefaultMonitoringVisitsService()
}


