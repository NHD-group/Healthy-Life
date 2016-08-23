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
            
            contentView.backgroundColor = Configuration.Colors.lightGray
            Configuration.Colors.lightGray

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
