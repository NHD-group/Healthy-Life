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
import YoutubeSourceParserKit
import YouTubePlayer
import MBProgressHUD

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

class NHDVideoPlayerViewController: BaseViewController {

    @IBOutlet weak var doneButton: NHDCustomSubmitGreenButton!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var midBar: UIView!
    @IBOutlet weak var movieContainer: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var rateLabel: UILabel!

    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var titleLabel: NHDCustomBoldFontLabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var webContain: UIView!
    @IBOutlet weak var webview: UIWebView!
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
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
            
            if introView != nil && isYouTubeVideo == false {
                playButton.selected = true
                introView.removeFromSuperview()
                introView = nil
                NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.scheduledToHideControls), userInfo: nil, repeats: false)
            }
        }
    }
    var videoURL: NSURL? {
        didSet {
            if !isViewLoaded() {
                return
            }
            
            if avPlayer == nil {
                setupVideoPlayer()
            } else if videoURL != nil {
                self.asset = AVAsset(URL: videoURL!)
                let playerItem = AVPlayerItem(asset: self.asset!)
                avPlayer = AVPlayer(playerItem: playerItem)
            }
            
        }
    }
    var titleText: String?
    var avPlayerLayer : AVPlayerLayer!
    var avPlayer : AVPlayer!
    var defaultRate: Float = 1
    var duration: NSTimeInterval = 0
    var tapGesture: UITapGestureRecognizer?
    var isYouTubeVideo = false
    
    class func showPlayer(videoUrl: NSURL?, orLink videoLink: String?, title: String?, inViewController vc: UIViewController) {
        
        var view = vc.view
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        if let rootVC = Helper.getRootViewController() where vc.presentingViewController == nil  {
            view = rootVC.view
        }
        
        let splashView = NHDSplash(frame: view.frame)
        view.addSubview(splashView)
        splashView.snp_makeConstraints { (make) in
            make.edges.equalTo(view.snp_edges)
        }
        MBProgressHUD.showHUDAddedTo(splashView, animated: true)

        Helper.delay(0.05) {
            Configuration.isPlayingVideo = true
            let playerVC = NHDVideoPlayerViewController(nibName: String(NHDVideoPlayerViewController), bundle: nil)
            if let videoUrl = videoUrl {
                playerVC.playVideoWithURL(videoUrl, title: title)
            } else if let videoLink = videoLink {
                playerVC.playVideo(videoLink, title: title)
            }
            vc.presentViewController(playerVC, animated: true, completion: {
                MBProgressHUD.hideHUDForView(vc.view, animated: true)
            })
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        setupVideoPlayer()
        setupUI()
    }
    
    func setupVideoPlayer() {
        
        guard let videoURL = videoURL else {
            return
        }
        
        if videoURL.absoluteString.hasPrefix(Configuration.YouTubePath) {
            return
        }
        
        self.asset = AVAsset(URL: videoURL)
        let playerItem = AVPlayerItem(asset: self.asset!)
        avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.allowsExternalPlayback = true
        avPlayer.usesExternalPlaybackWhileExternalScreenIsActive = true
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        movieContainer.layer.insertSublayer(avPlayerLayer, atIndex: 0)
        avPlayerLayer.frame = movieContainer.bounds

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayer.currentItem)
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
        avPlayer.play()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tapGesture = tapGesture {
            movieContainer.removeGestureRecognizer(tapGesture)
        }
        avPlayer?.pause()
        avPlayerLayer = nil
        Configuration.isPlayingVideo = false
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
        if duration > 0 && slider.isFirstResponder() == false  {
            slider.value = Float(currentTime / duration)
        }
    }
    
    func tapOnContent(gesture: UITapGestureRecognizer?) {
        
        if isYouTubeVideo {
            return
        }
        
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

    func playVideo(videoUrl: String?, title: String?) {
        
        guard let videoUrl = videoUrl else {
            return
        }
        
        guard let url = NSURL(string: videoUrl) else {
            return
        }
        
        if videoUrl.hasPrefix(Configuration.YouTubePath) {
            Youtube.h264videosWithYoutubeURL(url, completion: { (videoInfo, error) -> Void in
                if let
                    videoURLString = videoInfo?["url"] as? String {
                    let contentURL = NSURL(string: videoURLString)
                    self.playVideoWithURL(contentURL, title: title)
                } else {
                    self.isYouTubeVideo = true
                    self.playVideoWithURL(url, title: title)
                    self.addYouTubePlayer()
                }
            })
        } else {
            playVideoWithURL(url, title: title)
        }
        
    }
    
    func playVideoWithURL(url: NSURL?, title: String?) {
        
        videoURL = url
        titleText = title
    }
    
    func addYouTubePlayer() {
        
        webview.delegate = self
        webview.loadRequest(NSURLRequest(URL: videoURL!))
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
    
    func itemDidFinishPlaying(notification: NSNotification) {
        
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
            avPlayer?.play()
        } else {
            avPlayer?.pause()
        }
        
    }
    
    @IBAction func onPrevTapped(sender: AnyObject) {
        
        defaultRate -= 0.1
        avPlayer?.rate = defaultRate
        rateLabel.text = String.localizedStringWithFormat("%0.1fx", defaultRate)
        playButton.selected = true
    }
    
    @IBAction func onNextTapped(sender: AnyObject) {
        
        defaultRate += 0.1
        avPlayer?.rate = defaultRate
        rateLabel.text = String.localizedStringWithFormat("%0.1fx", defaultRate)
        playButton.selected = true
    }
    
    
    func onSliderValChanged(slider: UISlider, forEvent event: UIEvent) {
        
        avPlayer?.pause()
        let sliderValue = NSTimeInterval(Double(slider.value) * duration)
        let timeScale = avPlayer?.currentItem?.asset.duration.timescale ?? 0
        
        avPlayer?.seekToTime(CMTimeMakeWithSeconds(sliderValue, timeScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { (bool) in
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
        
        
        view.backgroundColor = Configuration.Colors.darkBlue
        webContain.hidden = true
        slider.value = 0
        slider.addTarget(self, action: #selector(self.onSliderValChanged(_:forEvent:)), forControlEvents: .ValueChanged)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnContent(_:)))
        view.addGestureRecognizer(tapGesture!)
        
        titleLabel.text = titleText
        
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
        avPlayer?.volume = volume
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(NSNumber(float: volume), forKey: "kVolumeKey")
    }
    
    @IBAction func volumeTunerInteractionBegin(tuner : NHDCircularTuner) {
    }
    
    @IBAction func volumeTunerInteractionEnd(tuner : NHDCircularTuner) {
    }
    

}

extension NHDVideoPlayerViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        view.bringSubviewToFront(webContain)
        view.bringSubviewToFront(topBar)
        prevButton.hidden = true
        nextButton.hidden = true
        rateLabel.hidden = true
        topBar.backgroundColor = Configuration.Colors.primary
        webContain.hidden = false
    }
}
