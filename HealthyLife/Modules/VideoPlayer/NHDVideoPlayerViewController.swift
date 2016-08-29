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

    var asset: AVAsset?
    var videoURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let videoURL = videoURL else {
            return
        }
        
        player = AVPlayer(URL: videoURL)
        player?.play()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.asset = AVAsset(URL: videoURL)
            UIViewController.attemptRotationToDeviceOrientation()
        })

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)

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
        
        videoURL = url
        
        player = AVPlayer(URL: url)
        player?.play()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        if let videoTrack = asset?.tracksWithMediaType(AVMediaTypeVideo).first {
            let size = videoTrack.naturalSize
//            let txf = videoTrack.preferredTransform
            
            if size.width < size.height {
                return .Portrait
            }
        }

        return .Landscape
    }
    
    
    func itemDidFinishPlaying(notification:NSNotification) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
