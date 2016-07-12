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

    @IBOutlet weak var currentLocationLbl: UILabel!
    
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var getCurrentLocationBtn: UIButton!
    
    @IBOutlet weak var toggleLocatingBtn: UIButton!
    
    @IBOutlet weak var modeSwitcher: UISegmentedControl!
    
    private var disposeBag = DisposeBag()
    
    private var locatingSubscription: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        modeSwitcher.rx_value
            .map{
                return $0 != 0
            }
            .subscribe(getCurrentLocationBtn.rx_hidden)
            .addDisposableTo(disposeBag)
        
        modeSwitcher.rx_value
            .map{
                return $0 == 0
            }
            .subscribe(toggleLocatingBtn.rx_hidden)
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
                    .addDisposableTo(self.disposeBag)
            }
            .addDisposableTo(disposeBag)
        
        toggleLocatingBtn.rx_tap
            .subscribeNext{
                [unowned self]
                _ in
                if self.locatingSubscription == nil {
                    self.toggleLocatingBtn.setTitle("Stop", forState: .Normal)
                    self.locatingSubscription = RxLocationManager.Standard.locating
                        .map{
                            let coord = $0.last!;
                            return "\(coord.coordinate.latitude),\(coord.coordinate.longitude)"
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
                }else{
                    self.toggleLocatingBtn.setTitle("Start", forState: .Normal)
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
