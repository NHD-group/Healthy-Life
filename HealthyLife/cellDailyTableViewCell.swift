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
