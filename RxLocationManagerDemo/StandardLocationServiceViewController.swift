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
    
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var getCurrentLocationBtn: UIButton!
    
    @IBOutlet weak var modeSwitcher: UISegmentedControl!
    
    @IBOutlet weak var locatedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        modeSwitcher.rx_value
            .map{
                return $0 != 0
            }
            .subscribe(locatedView.rx_hidden)
            .addDisposableTo(disposeBag)
        
        getCurrentLocationBtn.rx_tap
            .subscribeNext{
                [unowned self]
                _ in
                RxLocationManager.Standard.located
                    .map{
                        return "\($0.coordinate.latitude),\($0.coordinate.longitude)"
                    }
                    .doOn{
                        switch $0{
                        case .Next(_):
                            self.errorLbl.text = ""
                        case .Error(let error as NSError):
                            self.currentLocationLbl.text = ""
                            self.errorLbl.text = error.description
                        default:
                            return
                        }
                    }
                    .catchErrorJustReturn("")
                    .subscribe(self.currentLocationLbl.rx_text)
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
