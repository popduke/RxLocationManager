//
//  SignificantLocationUpdateService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
#if os(OSX)
    import Foundation
    import CoreLocation
    import RxSwift
    
    //MARK: SignificantLocationUpdateService
    public protocol SignificantLocationUpdateService{
        var locating: Observable<[CLLocation]> {get}
    }
    
    //MARK: DefaultSignificantLocationUpdateService
    class DefaultSignificantLocationUpdateService: SignificantLocationUpdateService{
        private let locMgr = Bridge()
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
    
#endif