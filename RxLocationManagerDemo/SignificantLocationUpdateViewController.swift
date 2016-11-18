//
//  SignificantLocationUpdateViewController.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/12.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import RxLocationManager
import RxSwift
import RxCocoa

class SignificantLocationUpdateViewController: UIViewController {
    
    @IBOutlet weak var currentLocationLbl: UILabel!
    
    @IBOutlet weak var toggleSignificantLocationUpdateBtn: UIButton!
    
    private var disposeBag:DisposeBag!
    
    private var locatingSubscription: Disposable?
    override func viewWillAppear(_ animated: Bool) {
        disposeBag = DisposeBag()
        toggleSignificantLocationUpdateBtn.rx.tap
            .subscribe{
                [unowned self]
                _ in
                if self.locatingSubscription == nil {
                    self.toggleSignificantLocationUpdateBtn.setTitle("Stop", for: .normal)
                    self.locatingSubscription = RxLocationManager.SignificantLocation.locating
                        .map{
                            let coord = $0.last!;
                            return "\(coord.coordinate.latitude),\(coord.coordinate.longitude)"
                        }
                        .catchErrorJustReturn("")
                        .subscribe(self.currentLocationLbl.rx.text)
                }else{
                    self.toggleSignificantLocationUpdateBtn.setTitle("Start", for: .normal)
                    self.currentLocationLbl.text = ""
                    self.locatingSubscription!.dispose()
                    self.locatingSubscription = nil
                }
            }
            .addDisposableTo(disposeBag)
    }
    override func viewDidDisappear(_ animated: Bool) {
        disposeBag = nil
        locatingSubscription?.dispose()
        locatingSubscription = nil
    }
}
