//
//  ActivitiesDoneCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/18/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import NSDate_TimeAgo

class ActivitiesDoneCellTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var activityName: UILabel!
    
    @IBOutlet weak var backview: UIView!
    @IBOutlet weak var nameOfPlanLabel: UILabel!
    
    var activity: ActivitiesDone! {
        didSet {
           timeLabel.text = "\(activity!.time!.timeAgo())"
           activityName.text = "Exercise : " + (activity?.activityName)!
            nameOfPlanLabel.text = "Plan : " + (activity?.nameOfPlan)!
            
            
            contentView.backgroundColor = Configuration.Colors.lightGray
            Configuration.Colors.lightGray
            
            backview.layer.cornerRadius = 10
            backview.clipsToBounds = true
            

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
