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
import MediaPlayer

class NHDVideoPlayerViewController: BaseViewController {

    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var midBar: UIView!
    @IBOutlet weak var movieContainer: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var rateLabel: UILabel!

    @IBOutlet weak var titleLabel: NHDCustomBoldFontLabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var brightnessTuner : NHDCircularTuner!
    @IBOutlet weak var volumeTuner     : NHDCircularTuner!
    var volumeView = MPVolumeView(frame: CGRectZero)
    weak var volumeSlider : UISlider!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Configuration.Colors.lightGray
        titleLabel.text = titleText
        slider.value = 0
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnContent(_:)))
        view.addGestureRecognizer(tapGesture!)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        guard let videoURL = videoURL else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.asset = AVAsset(URL: videoURL)
        })
        
        avPlayer = AVPlayer(URL: videoURL)
        avPlayer.play()
        avPlayer.allowsExternalPlayback = true
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        movieContainer.layer.insertSublayer(avPlayerLayer, atIndex: 0)
        avPlayerLayer.frame = movieContainer.bounds
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayer.currentItem)
        
        avPlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)

        setupUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        avPlayer.removeObserver(self, forKeyPath: "status")
        if let tapGesture = tapGesture {
            movieContainer.removeGestureRecognizer(tapGesture)
        }
        avPlayer.pause()
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
            self.midBar.alpha = alpha
        }
    }
    
    func scheduledToHideControls() {
        UIView.animateWithDuration(Configuration.animationDuration) {
            self.topBar.alpha = 0.0
            self.bottomBar.alpha = 0.0
            self.midBar.alpha = 0.0
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            if let status = change?[NSKeyValueChangeNewKey] as? Int {
                if status == 1 {
                    playButton.selected = true
                
                    NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.scheduledToHideControls), userInfo: nil, repeats: false)
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
        playButton.selected = true
    }
    
    @IBAction func onNextTapped(sender: AnyObject) {
        
        defaultRate += 0.1
        avPlayer.rate = defaultRate
        rateLabel.text = String.localizedStringWithFormat("%0.1fx", defaultRate)
        playButton.selected = true
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

extension NHDVideoPlayerViewController {
    
    func setupUI() {
        brightnessTuner.image = UIImage(named: "ic_brightness")
        brightnessTuner.incompleteColor = Configuration.Colors.lightGray
        brightnessTuner.completeColor = UIColor.whiteColor()
        brightnessTuner.progress = Float(UIScreen.mainScreen().brightness)
        
        volumeTuner.flipped = true
        volumeTuner.image = UIImage(named: "ic_volume")
        volumeTuner.incompleteColor = Configuration.Colors.lightGray
        volumeTuner.completeColor = UIColor.whiteColor()
        
        volumeSlider = volumeView.volumeSlider
        let defaults = NSUserDefaults.standardUserDefaults()
        if let volume = defaults.valueForKey("kVolumeKey") as? NSNumber {
            volumeTuner.progress = volume.floatValue
            volumeSlider.value = volume.floatValue
        }
    }
    
    @IBAction func brightnessTunerInteractionBegin(tuner : NHDCircularTuner) {
    }
    
    @IBAction func brightnessTunerInteractionEnd(tuner : NHDCircularTuner) {
    }
    
    @IBAction func brightnessDidChanged(tuner : NHDCircularTuner) {
        let brightnessValue = tuner.progress
        UIScreen.mainScreen().brightness = CGFloat(brightnessValue)

    }
    
    @IBAction func volumeDidChanged(tuner : NHDCircularTuner) {
        let volume = tuner.progress
        volumeSlider.value = volume
        avPlayer.volume = volume
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(NSNumber(float: volume), forKey: "kVolumeKey")
    }
    
    @IBAction func volumeTunerInteractionBegin(tuner : NHDCircularTuner) {
    }
    
    @IBAction func volumeTunerInteractionEnd(tuner : NHDCircularTuner) {
    }
    

}


extension MPVolumeView {
    var volumeSlider:UISlider {
        var slider = UISlider()
        for subview in self.subviews {
            if subview.isKindOfClass(UISlider){
                slider = subview as! UISlider
                return slider
            }
        }
        return slider
    }
}
