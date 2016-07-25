//
//  SignificantLocationUpdateService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
#if os(iOS) || os(OSX)
    import Foundation
    import CoreLocation
    import RxSwift
    
    //MARK: SignificantLocationUpdateService
    public protocol SignificantLocationUpdateService{
        /// Observable of current significant location change
        var locating: Observable<[CLLocation]> {get}
    }
    
    //MARK: DefaultSignificantLocationUpdateService
    class DefaultSignificantLocationUpdateService: SignificantLocationUpdateService{
        let locMgr:LocationManagerBridge
        private var observers = [(id: Int, AnyObserver<[CLLocation]>)]()
        var locating: Observable<[CLLocation]>{
            get{
                return Observable.create {
                    observer in
                    var ownerService: DefaultSignificantLocationUpdateService! = self
                    let id = nextId()
                    ownerService.observers.append((id, observer))
                    ownerService.locMgr.startMonitoringSignificantLocationChanges()
                    return AnonymousDisposable {
                        ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                        if(ownerService.observers.count == 0){
                            ownerService.locMgr.stopMonitoringSignificantLocationChanges()
                        }
                        ownerService = nil
                    }
                }
            }
        }
        
        init(bridgeClass: LocationManagerBridge.Type){
            locMgr = bridgeClass.init()
            locMgr.didUpdateLocations = {
                [weak self]
                mgr, locations in
                if let copyOfObservers = self?.observers{
                    for (_,observer) in copyOfObservers{
                        #if os(OSX)
                            observer.onNext(locations as! [CLLocation])
                        #else
                            observer.onNext(locations)
                        #endif
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
#endif