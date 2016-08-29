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
    
    var asset: AVAsset? {
        didSet {
            
            guard let asset = asset else {
                return
            }
            UIViewController.attemptRotationToDeviceOrientation()
            duration = CMTimeGetSeconds(asset.duration)
            totalTimeLabel.text = duration.readableDurationString()
        }
    }
    var videoURL: NSURL?
    var titleText: String?
    var avPlayerLayer : AVPlayerLayer!
    var avPlayer : AVPlayer!
    var defaultRate: Float = 1
    var duration: NSTimeInterval = 0
    var tapGesture: UITapGestureRecognizer?
    var scheduledToHideControlsTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Configuration.Colors.lightGray
        titleLabel.text = titleText
        slider.value = 0
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnContent(_:)))
        movieContainer.addGestureRecognizer(tapGesture!)

    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        guard let videoURL = videoURL else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.asset = AVAsset(URL: videoURL)
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
        
//        avPlayer.addPeriodicTimeObserverForInterval(CMTime(seconds: 1, preferredTimescale: 0), queue: dispatch_get_main_queue()) { (time) in
//            let currentTime = CMTimeGetSeconds(time)
//            self.currentTimeLabel.text = currentTime.readableDurationString()
//            if self.duration > 0 {
//                self.slider.value = Float(currentTime / self.duration)
//            }
//        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        avPlayer.removeObserver(self, forKeyPath: "status")
//        avPlayer.removeTimeObserver(self)
        if let tapGesture = tapGesture {
            movieContainer.removeGestureRecognizer(tapGesture)
        }
    }
    
    func hideOrShowControlBar() {
        tapOnContent(tapGesture)

    }
    func updateCurrentTime() {
        
        guard let currentItem = avPlayer?.currentItem else {
            return
        }
        
        let currentTime = CMTimeGetSeconds(currentItem.currentTime())
        currentTimeLabel.text = currentTime.readableDurationString()
        if duration > 0 {
            slider.value = Float(currentTime / duration)
        }
    }
    
    func tapOnContent(gesture: UITapGestureRecognizer?) {
        
        let alpha = 1.0 - topBar.alpha
        
        
        UIView.animateWithDuration(Configuration.animationDuration) {
            self.topBar.alpha = alpha
            self.bottomBar.alpha = alpha
        }
    }
    
    func scheduledToHideControls() {
        UIView.animateWithDuration(Configuration.animationDuration) {
            self.topBar.alpha = 0.0
            self.bottomBar.alpha = 0.0
        }
        scheduledToHideControlsTimer?.invalidate()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            if let status = change?[NSKeyValueChangeNewKey] as? Int {
                if status == 1 {
                    playButton.selected = true
                
                    scheduledToHideControlsTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.scheduledToHideControls), userInfo: nil, repeats: false)
                }
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
    
    @IBAction func sliderChangeValue(slider: UISlider) {
        
        avPlayer.pause()
        let sliderValue = NSTimeInterval(Double(slider.value) * duration)
        let timeScale = avPlayer.currentItem?.asset.duration.timescale ?? 0

        avPlayer.seekToTime(CMTimeMakeWithSeconds(sliderValue, timeScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { (bool) in
            self.avPlayer.play()
        }
        
    }
    
    @IBAction func onClose(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
