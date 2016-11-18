//
//  ViewController.swift
//  RxLocationManagerDemo
//
//  Created by Yonny Hao on 16/7/10.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import RxLocationManager

class RootViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var requestWhenInUseBtn: UIButton!
    
    @IBOutlet weak var requestAlwaysBtn: UIButton!
    
    @IBOutlet weak var standardLocationServiceBtn: UIButton!
    
    @IBOutlet weak var locationServiceStatusLbl: UILabel!
    
    @IBOutlet weak var significantLocationUpdateBtn: UIButton!
    
    @IBOutlet weak var headingUpdateServiceBtn: UIButton!
    
    @IBOutlet weak var regionMonitoringServiceBtn: UIButton!
    
    @IBOutlet weak var authStatusLbl: UILabel!
    
    @IBOutlet weak var visitMonitoringServiceBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isAuthorized = RxLocationManager.authorizationStatus.map{return $0 == .authorizedAlways || $0 == .authorizedWhenInUse}
        
        isAuthorized.subscribe(standardLocationServiceBtn.rx.isEnabled).addDisposableTo(disposeBag)
        isAuthorized.subscribe(visitMonitoringServiceBtn.rx.isEnabled).addDisposableTo(disposeBag)
        
        isAuthorized.map{
            $0 && RxLocationManager.significantLocationChangeMonitoringAvailable
            }
            .bindTo(significantLocationUpdateBtn.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        isAuthorized.map{
            $0 && RxLocationManager.headingAvailable
            }
            .bindTo(headingUpdateServiceBtn.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        isAuthorized.map{
            $0 && RxLocationManager.isMonitoringAvailableForClass(regionClass: CLCircularRegion.self)
            }
            .bindTo(regionMonitoringServiceBtn.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        requestWhenInUseBtn.rx.tap
            .subscribe(
                onNext:{
                    _ in
                    RxLocationManager.requestWhenInUseAuthorization()
            })
            .addDisposableTo(disposeBag)
        
        requestAlwaysBtn.rx.tap
            .subscribe(
                onNext:{
                    _ in
                    RxLocationManager.requestAlwaysAuthorization()
            })
            .addDisposableTo(disposeBag)
        
        RxLocationManager.enabled
            .map{return "Location Service is \($0 ? "ON":"OFF")"}
            .bindTo(locationServiceStatusLbl.rx.text)
            .addDisposableTo(disposeBag)
        
        RxLocationManager.authorizationStatus
            .map {
                switch($0){
                case .notDetermined:
                    return "NotDetermined"
                case .restricted:
                    return "Restricted"
                case .denied:
                    return "Denied"
                case .authorizedAlways:
                    return "AuthorizedAlways"
                case .authorizedWhenInUse:
                    return "AuthorizedWhenInUse"
                }
            }
            .map {
                return "Authorization Status is " + $0
            }
            .bindTo(authStatusLbl.rx.text)
            .addDisposableTo(disposeBag)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

