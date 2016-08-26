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
    
    @IBOutlet weak var photoView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var video: Video! {
        didSet {
            nameVidLabel.text = video.name
            desVidLabel.text = video.des
            photoView.downloadImageWithKey(video.key)
        }
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
