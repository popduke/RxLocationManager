//
//  MonitoredCircleRegionTableViewCell.swift
//  RxLocationManager
//
//  Created by Yonny Hao on 16/7/14.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import CoreLocation

class MonitoredCircleRegionTableViewCell: UITableViewCell {
    @IBOutlet weak var centerCoordLbl: UILabel!
    
    @IBOutlet weak var inoutStatusLbl: UILabel!
    
    var monitoredRegion: CLCircularRegion?{
        didSet{
            if let region = monitoredRegion{
                centerCoordLbl.text = "\(region.center.latitude),\(region.center.longitude)"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
