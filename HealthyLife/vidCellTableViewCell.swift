//
//  vidCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class vidCellTableViewCell: UITableViewCell {

    @IBOutlet weak var nameVidLabel: UILabel!
    
    @IBOutlet weak var desVidLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var video: Video! {
        didSet {
            nameVidLabel.text = video.name as? String
            desVidLabel.text = video.des as? String
            
        }
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
