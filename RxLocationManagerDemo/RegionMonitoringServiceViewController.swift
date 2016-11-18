//
//  RegionMonitoringServiceViewController.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/14.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import CoreLocation
import RxLocationManager
import RxSwift

extension CLRegionState: CustomStringConvertible{
    public var description:String{
        get{
            switch self{
            case .unknown:
                return "Unknown"
            case .inside:
                return "IN"
            case .outside:
                return "OUT"
            }
        }
    }
}

class RegionMonitoringServiceViewController: UIViewController {

    @IBOutlet weak var addRegionBtn: UIButton!
    
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var monitoredRangesTableView: UITableView!
    
    private var disposeBag:DisposeBag!
    
    override func viewWillAppear(_ animated: Bool) {
        disposeBag = DisposeBag()
        addRegionBtn.rx.tap
            .subscribe{
                [unowned self]
                _ in
                self.errorLbl.text = ""
                RxLocationManager.Standard.located
                    .do(onError:{
                        self.errorLbl.text = ($0 as NSError).description
                    })
                    .subscribe(onNext:{
                        location in
                        _ = RxLocationManager.RegionMonitoring.startMonitoringForRegions([CLCircularRegion(center: location.coordinate, radius: 20, identifier: location.timestamp.description)])
                    })
                    .addDisposableTo(self.disposeBag)
            }
            .addDisposableTo(disposeBag)
        
        RxLocationManager.RegionMonitoring.error
            .subscribe(onNext:{
                [unowned self]
                region, error in
                self.errorLbl.text = error.description
            })
            .addDisposableTo(disposeBag)

        RxLocationManager.RegionMonitoring.monitoredRegions
            .bindTo(monitoredRangesTableView.rx.items) { (tableView, row, monitoredRegion) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "MonitoredRegionTableViewCell")! as! MonitoredCircleRegionTableViewCell
                cell.monitoredRegion = monitoredRegion as? CLCircularRegion
                return cell
            }
            .addDisposableTo(disposeBag)
        
        monitoredRangesTableView.rx.itemDeleted
            .subscribe(onNext:{
                [unowned self]
                indexOfRemovedRegion in
                let removedRegionCell = self.monitoredRangesTableView.cellForRow(at: indexOfRemovedRegion) as! MonitoredCircleRegionTableViewCell
                _ = RxLocationManager.RegionMonitoring.stopMonitoringForRegions([removedRegionCell.monitoredRegion!])
            })
            .addDisposableTo(disposeBag)
        
        RxLocationManager.RegionMonitoring.entering
            .subscribe(onNext:{
                [unowned self]
                enteredRegion in
                for i in 0 ..< self.monitoredRangesTableView.numberOfSections {
                    for j in 0 ..< self.monitoredRangesTableView.numberOfRows(inSection: i){
                        if let cell = self.monitoredRangesTableView.cellForRow(at:IndexPath(row: j, section: i)){
                            let monitoredCell = cell as! MonitoredCircleRegionTableViewCell
                            if monitoredCell.monitoredRegion!.identifier == enteredRegion.identifier{
                                monitoredCell.inoutStatusLbl!.text = "IN"
                            }
                        }
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        RxLocationManager.RegionMonitoring.exiting
            .subscribe(onNext:{
                [unowned self]
                exitedRegion in
                for i in 0 ..< self.monitoredRangesTableView.numberOfSections {
                    for j in 0 ..< self.monitoredRangesTableView.numberOfRows(inSection: i){
                        if let cell = self.monitoredRangesTableView.cellForRow(at:IndexPath(row: j, section: i)){
                            let monitoredCell = cell as! MonitoredCircleRegionTableViewCell
                            if monitoredCell.monitoredRegion!.identifier == exitedRegion.identifier{
                                monitoredCell.inoutStatusLbl!.text = "OUT"
                            }
                        }
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        monitoredRangesTableView.rx.itemSelected
            .subscribe(onNext:{
                [unowned self]
                indexPath in
                let monitoredCell = self.monitoredRangesTableView.cellForRow(at:indexPath) as! MonitoredCircleRegionTableViewCell
                _ = RxLocationManager.RegionMonitoring.requestRegionsState([monitoredCell.monitoredRegion!])
            })
        .addDisposableTo(disposeBag)
        
        RxLocationManager.RegionMonitoring.determinedRegionState
            .subscribe(onNext:{
                [unowned self]
                region, state in
                for i in 0 ..< self.monitoredRangesTableView.numberOfSections {
                    for j in 0 ..< self.monitoredRangesTableView.numberOfRows(inSection: i){
                        if let cell = self.monitoredRangesTableView.cellForRow(at: IndexPath(row: j, section: i)){
                            let monitoredCell = cell as! MonitoredCircleRegionTableViewCell
                            if monitoredCell.monitoredRegion!.identifier == region.identifier{
                                monitoredCell.inoutStatusLbl!.text = state.description
                            }
                        }
                    }
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposeBag = nil
    }
}
