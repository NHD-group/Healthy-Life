//
//  cellDailyTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/23/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class cellDailyTableViewCell: UITableViewCell {

    @IBOutlet weak var backview: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    
    var activity: Activities! {
        didSet {
            nameLabel.text = activity.name
            descripLabel.text = activity.des
            contentView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            
            backview.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
            
            backview.layer.shadowOffset = CGSize(width: 0, height: 0)
            backview.layer.shadowOpacity = 0.8
            
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
