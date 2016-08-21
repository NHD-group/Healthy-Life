//
//  commentCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/17/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import NSDate_TimeAgo

class commentCellTableViewCell: UITableViewCell {

    @IBOutlet weak var commentTextLabel: UILabel!
    
    @IBOutlet weak var timeStampTextLabel: UILabel!
    
    @IBOutlet weak var backView: UILabel!
    
    
    var comment: Comment? {
        didSet {
            commentTextLabel.text = comment?.text
            timeStampTextLabel.text = "\(comment!.time!.timeAgo())"
            
            contentView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            
            backView.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
            
            backView.layer.shadowOffset = CGSize(width: 0, height: 0)
            backView.layer.shadowOpacity = 0.8

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
