//
//  ViewController.swift
//  RxLocationManagerDemo
//
//  Created by Hao Yu on 16/7/10.
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
    
    @IBOutlet weak var locationServiceStatusLbl: UILabel!
    
    @IBOutlet weak var significantLocationUpdateBtn: UIButton!
    
    @IBOutlet weak var headingUpdateServiceBtn: UIButton!
    
    @IBOutlet weak var regionMonitoringServiceBtn: UIButton!
    
    @IBOutlet weak var authStatusLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        significantLocationUpdateBtn.enabled = RxLocationManager.significantLocationChangeMonitoringAvailable
        
        headingUpdateServiceBtn.enabled = RxLocationManager.headingAvailable
        
        regionMonitoringServiceBtn.enabled = RxLocationManager.isRangingAvailable
        
        RxLocationManager.authorizationStatus
            .map{return $0 == CLAuthorizationStatus.NotDetermined}
            .subscribe(requestWhenInUseBtn.rx_enabled)
        
        RxLocationManager.authorizationStatus
            .map{return $0 == CLAuthorizationStatus.NotDetermined}
            .subscribe(requestAlwaysBtn.rx_enabled)
        
        requestWhenInUseBtn.rx_tap.subscribeNext{
            RxLocationManager.requestWhenInUseAuthorization()
        }
        .addDisposableTo(disposeBag)
        
        requestAlwaysBtn.rx_tap.subscribeNext{
            RxLocationManager.requestAlwaysAuthorization()
        }
        .addDisposableTo(disposeBag)
        
        RxLocationManager.enabled
            .map{return "Location Service is \($0 ? "ON":"OFF")"}
            .subscribe(locationServiceStatusLbl.rx_text)
            .addDisposableTo(disposeBag)
        
        RxLocationManager.authorizationStatus
            .map {
                switch($0){
                case .NotDetermined:
                    return "NotDetermined"
                case .Restricted:
                    return "Restricted"
                case .Denied:
                    return "Denied"
                case .AuthorizedAlways:
                    return "AuthorizedAlways"
                case .AuthorizedWhenInUse:
                    return "AuthorizedWhenInUse"
                }
            }
            .map {
                return "Authorization Status is " + $0
            }
            .subscribe(authStatusLbl.rx_text)
            .addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

