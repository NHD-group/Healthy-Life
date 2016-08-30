//
//  NHDYouTubeTableViewCell.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 30/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

protocol NHDYouTubeTableViewCellDelegate: class {
    func onChooseVideo(video: NHDYouTubeModel)
}

class NHDYouTubeTableViewCell: BaseTableViewCell {

    var selectedVideo: NHDYouTubeModel?
    weak var delegate: NHDYouTubeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func initWithData(video: NHDYouTubeModel) {
        
        titleLabel.text = video.title
        thumbnailView.kf_setImageWithURL(NSURL(string: video.thumbnail))
        selectedVideo = video
    }
    
    @IBAction func onChooseVideo(sender: AnyObject) {
        
        if let video = selectedVideo {
            delegate?.onChooseVideo(video)
        }
    }
    
}
