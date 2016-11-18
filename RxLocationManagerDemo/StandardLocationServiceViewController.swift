//
//  StandardLocationServiceViewController.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/10.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import RxLocationManager
import RxSwift
import RxCocoa

class StandardLocationServiceViewController: UIViewController {
    
    @IBOutlet weak var currentLocationLbl: UILabel!
    
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var getCurrentLocationBtn: UIButton!
    
    @IBOutlet weak var toggleLocatingBtn: UIButton!
    
    @IBOutlet weak var modeSwitcher: UISegmentedControl!
    
    private var disposeBag:DisposeBag!
    
    private var locatedSubscription: Disposable?
    private var locatingSubscription: Disposable?
    
    override func viewWillAppear(_ animated: Bool) {
        disposeBag = DisposeBag()
        modeSwitcher.rx.value
            .map{
                return $0 != 0
            }
            .subscribe(getCurrentLocationBtn.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        modeSwitcher.rx.value
            .map{
                return $0 == 0
            }
            .subscribe(toggleLocatingBtn.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        getCurrentLocationBtn.rx.tap
            .subscribe{
                [unowned self]
                _ in
                if self.locatedSubscription != nil {
                    self.currentLocationLbl.text = ""
                    self.locatedSubscription!.dispose()
                }
                self.locatedSubscription = RxLocationManager.Standard.located
                    .map{
                        return "\($0.coordinate.latitude),\($0.coordinate.longitude)"
                    }
                    .do(
                        onNext:{
                            _ in
                            self.errorLbl.text = ""
                        },
                        onError:{
                            self.currentLocationLbl.text = ""
                            self.errorLbl.text = ($0 as NSError).description
                        }
                    )
                    .catchErrorJustReturn("")
                    .bindTo(self.currentLocationLbl.rx.text)
            }
            .addDisposableTo(disposeBag)
        
        toggleLocatingBtn.rx.tap
            .subscribe{
                [unowned self]
                _ in
                if self.locatingSubscription == nil {
                    self.toggleLocatingBtn.setTitle("Stop", for: .normal)
                    self.locatingSubscription = RxLocationManager.Standard.locating
                        .map{
                            let coord = $0.last!;
                            return "\(coord.coordinate.latitude),\(coord.coordinate.longitude)"
                        }
                        .do(
                            onNext:{
                                _ in
                                self.errorLbl.text = ""
                            },
                            onError:{
                                self.currentLocationLbl.text = ""
                                self.errorLbl.text = ($0 as NSError).description
                            }
                        )
                        .catchErrorJustReturn("")
                        .bindTo(self.currentLocationLbl.rx.text)
                }else{
                    self.toggleLocatingBtn.setTitle("Start", for: .normal)
                    self.currentLocationLbl.text = ""
                    self.locatingSubscription!.dispose()
                    self.locatingSubscription = nil
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposeBag = nil
        locatedSubscription?.dispose()
        locatedSubscription = nil
        locatingSubscription?.dispose()
        locatingSubscription = nil
    }
}
