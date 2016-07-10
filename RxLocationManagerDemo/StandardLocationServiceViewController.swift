//
//  StandardLocationServiceViewController.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/10.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import RxLocationManager
import RxSwift
import RxCocoa

class StandardLocationServiceViewController: UIViewController {
    var disposeBag = DisposeBag()
    @IBOutlet weak var currentLocationLbl: UILabel!
    
    @IBOutlet weak var getCurrentLocationBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        getCurrentLocationBtn.rx_tap
            .flatMap{
                return RxLocationManager.Standard.located
            }
            .map{
                return "Current Location: \($0.description)"
            }
            .subscribe(currentLocationLbl.rx_text)
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
