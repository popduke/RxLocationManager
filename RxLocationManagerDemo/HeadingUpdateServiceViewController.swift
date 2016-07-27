//
//  HeadingUpdateServiceViewController.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/13.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxLocationManager

class HeadingUpdateServiceViewController: UIViewController {

    @IBOutlet weak var magneticHeadingValueLbl: UILabel!
    
    @IBOutlet weak var trueHeadingValueLbl: UILabel!
    
    @IBOutlet weak var headingAccuracyValueLbl: UILabel!
    
    @IBOutlet weak var timestampValueLbl: UILabel!
    
    @IBOutlet weak var toggleHeadingUpdateBtn: UIButton!
    
    @IBOutlet weak var trueHeadingSwitch: UISwitch!
    
    private var disposeBag: DisposeBag!
    
    private var headingSubscription: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        disposeBag = DisposeBag()
        trueHeadingSwitch.rx_value
            .subscribeNext{
                if $0{
                    RxLocationManager.HeadingUpdate.startTrueHeading(nil)
                }else{
                    RxLocationManager.HeadingUpdate.stopTrueHeading()
                }
                
            }
            .addDisposableTo(disposeBag)
        
        toggleHeadingUpdateBtn.rx_tap
            .subscribeNext{
                [unowned self]
                _ in
                if self.headingSubscription == nil {
                    self.toggleHeadingUpdateBtn.setTitle("Stop", forState: .Normal)
                    self.headingSubscription = RxLocationManager.HeadingUpdate.heading
                        .subscribeNext{
                            [unowned self]
                            heading in
                            self.magneticHeadingValueLbl.text = heading.magneticHeading.description
                            self.trueHeadingValueLbl.text = heading.trueHeading.description
                            self.headingAccuracyValueLbl.text = heading.headingAccuracy.description
                            self.timestampValueLbl.text = heading.timestamp.description
                    }
                }else{
                    self.headingSubscription?.dispose()
                    self.toggleHeadingUpdateBtn.setTitle("Start", forState: .Normal)
                    self.magneticHeadingValueLbl.text = ""
                    self.trueHeadingValueLbl.text = ""
                    self.headingAccuracyValueLbl.text = ""
                    self.timestampValueLbl.text = ""
                    self.headingSubscription!.dispose()
                    self.headingSubscription = nil
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidDisappear(animated: Bool) {
        disposeBag = nil
        headingSubscription?.dispose()
        headingSubscription = nil
    }
}
