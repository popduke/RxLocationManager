//
//  SignificantLocationUpdateViewController.swift
//  RxLocationManager
//
//  Created by HaoYu on 16/7/12.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import RxLocationManager
import RxSwift
import RxCocoa

class SignificantLocationUpdateViewController: UIViewController {
    
    @IBOutlet weak var currentLocationLbl: UILabel!
    
    @IBOutlet weak var toggleSignificantLocationUpdateBtn: UIButton!
    
    private var disposeBag = DisposeBag()
    
    private var locatingSubscription: Disposable?
    override func viewDidLoad() {
        super.viewDidLoad()

        toggleSignificantLocationUpdateBtn.rx_tap
            .subscribeNext{
                [unowned self]
                _ in
                if self.locatingSubscription == nil {
                    self.toggleSignificantLocationUpdateBtn.setTitle("Stop", forState: .Normal)
                    self.locatingSubscription = RxLocationManager.SignificantLocation.locating
                        .map{
                            let coord = $0.last!;
                            return "\(coord.coordinate.latitude),\(coord.coordinate.longitude)"
                        }
                        .catchErrorJustReturn("")
                        .subscribe(self.currentLocationLbl.rx_text)
                }else{
                    self.toggleSignificantLocationUpdateBtn.setTitle("Start", forState: .Normal)
                    self.currentLocationLbl.text = ""
                    self.locatingSubscription!.dispose()
                    self.locatingSubscription = nil
                }
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
