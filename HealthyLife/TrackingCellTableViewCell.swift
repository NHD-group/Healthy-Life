//
//  TrackingCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/7/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit

class TrackingCellTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var activityWorkinLabel: UILabel!
    
    
    @IBOutlet weak var workImage: UIImageView!
    
    
    var tracking: Tracking! {
        didSet {
            usernameLabel.text = tracking.name as? String
            if tracking.workingOn != nil {
                activityWorkinLabel.text = tracking.nameOfActivity as? String
                workImage.image = UIImage(named: "online")
            } else {
                activityWorkinLabel.text = ""
                workImage.image = UIImage(named: "offline")
                
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
