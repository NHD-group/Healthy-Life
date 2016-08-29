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

class NHDVideoPlayerViewController: BaseViewController {

    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var movieContainer: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var rateLabel: UILabel!

    @IBOutlet weak var titleLabel: NHDCustomBoldFontLabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    var asset: AVAsset?
    var videoURL: NSURL?
    var titleText: String?
    var avPlayerLayer : AVPlayerLayer!
    var avPlayer : AVPlayer!
    var defaultRate: Float = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Configuration.Colors.lightGray
        titleLabel.text = titleText
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        guard let videoURL = videoURL else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.asset = AVAsset(URL: videoURL)
            UIViewController.attemptRotationToDeviceOrientation()
        })
        
        
//        showLoading()
        
        avPlayer = AVPlayer(URL: videoURL)
        avPlayer.play()
        avPlayer.allowsExternalPlayback = true
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        movieContainer.layer.insertSublayer(avPlayerLayer, atIndex: 0)
        avPlayerLayer.frame = movieContainer.bounds
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayer.currentItem)
        
        avPlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        avPlayer.removeObserver(self, forKeyPath: "status")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            if let status = change?[NSKeyValueChangeNewKey] as? Int {
                if status == 1 {
                    playButton.selected = true
                }
                print(status)
            }
        }
    }


    func playVideo(videoUrl: String?, title: String?) {
        
        guard let videoUrl = videoUrl else {
            return
        }
        
        let url = NSURL(string: videoUrl)
        playVideoWithURL(url, title: title)
    }

    func playVideoWithURL(url: NSURL?, title: String?) {
        
        videoURL = url
        titleText = title
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func itemDidFinishPlaying(notification:NSNotification) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        if let avPlayerLayer = avPlayerLayer {
            avPlayerLayer.frame = movieContainer.bounds
        }
    }
    
    @IBAction func onPlayTapped(button: UIButton) {
        
        button.selected = !button.selected

        if button.selected {
            avPlayer.play()
        } else {
            avPlayer.pause()
        }
        
    }
    
    @IBAction func onPrevTapped(sender: AnyObject) {
        
        defaultRate -= 0.1
        avPlayer.rate = defaultRate
        rateLabel.text = String.localizedStringWithFormat("%0.1fx", defaultRate)
    }
    
    @IBAction func onNextTapped(sender: AnyObject) {
        
        defaultRate += 0.1
        avPlayer.rate = defaultRate
        rateLabel.text = String.localizedStringWithFormat("%0.1fx", defaultRate)
    }
    
    @IBAction func sliderChangeValue(sender: AnyObject) {
    }
    @IBAction func onClose(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
