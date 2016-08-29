//
//  NHDVideoPlayerViewController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 29/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class NHDVideoPlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func playVideo(videoUrl: String?) {
        
        guard let videoUrl = videoUrl else {
            return
        }
        
        let url = NSURL(string: videoUrl)
        playVideoWithURL(url)
    }

    func playVideoWithURL(url: NSURL?) {
        
        guard let url = url else {
            return
        }
        
        player = AVPlayer(URL: url)
        player?.play()
    }
}
