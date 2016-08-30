//
//  vidCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class vidCellTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var desVidLabel: UILabel!
    @IBOutlet weak var createPlanButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var video: Video! {
        didSet {
            titleLabel.text = video.name
            desVidLabel.text = video.des
            thumbnailView.downloadImageWithKey(video.key)
        }
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
