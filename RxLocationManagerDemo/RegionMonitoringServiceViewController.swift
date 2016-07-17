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
    
    private var disposeBag:DisposeBag!
    
    override func viewWillAppear(animated: Bool) {
        disposeBag = DisposeBag()
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
                        RxLocationManager.RegionMonitoring.startMonitoringForRegions([CLCircularRegion(center: location.coordinate, radius: 20, identifier: location.timestamp.description)])
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
        
        RxLocationManager.RegionMonitoring.entering
            .subscribeNext{
                [unowned self]
                enteredRegion in
                for i in 0 ..< self.monitoredRangesTableView.numberOfSections {
                    for j in 0 ..< self.monitoredRangesTableView.numberOfRowsInSection(i){
                        if let cell = self.monitoredRangesTableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)){
                            let monitoredCell = cell as! MonitoredCircleRegionTableViewCell
                            if monitoredCell.monitoredRegion!.identifier == enteredRegion.identifier{
                                monitoredCell.inoutStatusLbl!.text = "IN"
                            }
                        }
                    }
                }
            }
            .addDisposableTo(disposeBag)
        
        RxLocationManager.RegionMonitoring.exiting
            .subscribeNext{
                [unowned self]
                exitedRegion in
                for i in 0 ..< self.monitoredRangesTableView.numberOfSections {
                    for j in 0 ..< self.monitoredRangesTableView.numberOfRowsInSection(i){
                        if let cell = self.monitoredRangesTableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)){
                            let monitoredCell = cell as! MonitoredCircleRegionTableViewCell
                            if monitoredCell.monitoredRegion!.identifier == exitedRegion.identifier{
                                monitoredCell.inoutStatusLbl!.text = "OUT"
                            }
                        }
                    }
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidDisappear(animated: Bool) {
        disposeBag = nil
    }
}
