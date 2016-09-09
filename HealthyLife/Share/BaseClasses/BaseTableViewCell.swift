//
//  BaseTableViewCell.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 30/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var conerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        conerView?.layer.cornerRadius = 5
        conerView?.layer.masksToBounds = true
        conerView?.backgroundColor = UIColor.whiteColor()
        backgroundColor = UIColor.clearColor()
        
        thumbnailView?.layer.cornerRadius = 5
        thumbnailView?.layer.masksToBounds = true
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
