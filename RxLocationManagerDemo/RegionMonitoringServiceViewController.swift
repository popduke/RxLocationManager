//
//  RegionMonitoringServiceViewController.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/14.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import CoreLocation
import RxLocationManager
import RxSwift

class RegionMonitoringServiceViewController: UIViewController {

    @IBOutlet weak var addRegionBtn: UIButton!
    
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var monitoredRangesTableView: UITableView!
    
    private var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        addRegionBtn.rx_tap
            .subscribeNext{
                [unowned self]
                _ in
                self.errorLbl.text = ""
                RxLocationManager.Standard.located
                    .doOnError{
                        self.errorLbl.text = ($0 as NSError).description
                    }
                    .subscribeNext{
                        location in
                        RxLocationManager.RegionMonitoring.startMonitoringForRegions([CLCircularRegion(center: location.coordinate, radius: 5, identifier: location.timestamp.description)])
                    }
                    .addDisposableTo(self.disposeBag)
            }
            .addDisposableTo(disposeBag)
        
        RxLocationManager.RegionMonitoring.error
            .subscribeNext{
                [unowned self]
                region, error in
                self.errorLbl.text = error.description
            }
            .addDisposableTo(disposeBag)

        RxLocationManager.RegionMonitoring.monitoredRegions
            .bindTo(monitoredRangesTableView.rx_itemsWithCellFactory) { (tableView, row, monitoredRegion) in
                let cell = tableView.dequeueReusableCellWithIdentifier("MonitoredRegionTableViewCell")! as! MonitoredCircleRegionTableViewCell
                cell.monitoredRegion = monitoredRegion as? CLCircularRegion
                return cell
            }
            .addDisposableTo(disposeBag)
        
        monitoredRangesTableView.rx_itemDeleted
            .subscribeNext{
                [unowned self]
                indexOfRemovedRegion in
                let removedRegionCell = self.monitoredRangesTableView.cellForRowAtIndexPath(indexOfRemovedRegion) as! MonitoredCircleRegionTableViewCell
                RxLocationManager.RegionMonitoring.stopMonitoringForRegions([removedRegionCell.monitoredRegion!])
            }
            .addDisposableTo(disposeBag)
        // Do any additional setup after loading the view.
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
