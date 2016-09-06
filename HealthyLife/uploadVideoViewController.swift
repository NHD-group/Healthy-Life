//
//  uploadVideoViewController.swift
//  HealthyLife
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//


import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import MBProgressHUD
import DKImagePickerController
import SnapKit

class uploadVideoViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var nameVideoTextField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var desTextField: UITextField!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var pickerContainer: UIView!
    
    var videoUrl: NSURL? {
        didSet {
            playIcon?.hidden = isYouTubeVideo
        }
    }
    var isYouTubeVideo = false
    var pickerController: NHDImagePickerController!
    var assets: [DKAsset]? {
        didSet {
            guard let asset = assets?.first else {
                if !isYouTubeVideo {
                    resultImage.image = UIImage(named: "placeholder")
                    videoUrl = nil
                    playIcon.hidden = false
                }
                return
            }
            playIcon.hidden = false
            asset.fetchImageWithSize(Configuration.defaultPhotoSize) { [unowned self] (image, info) in
                self.resultImage.image = image
            }
            asset.fetchAVAssetWithCompleteBlock { [unowned self] (AVAsset, info) in
                if let urlAsset = AVAsset as? AVURLAsset {
                    self.videoUrl = urlAsset.URL
                }
            }
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        if videoUrl != nil {
            resultImage.thumbnailForVideoAtURL(videoUrl!)
        }
        
        title = "Upload Video"
        resultImage.contentMode = .ScaleAspectFit
        
        let tapToChoosePhotoGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseImageAction(_:)))
        resultImage.addGestureRecognizer(tapToChoosePhotoGesture)
        resultImage.userInteractionEnabled = true
        
        MBProgressHUD.showHUDAddedTo(pickerContainer, animated: true)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupPicker()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.getNotificationUploadVideo), name: Configuration.NotificationKey.uploadVideo, object: nil)

    }
    
    func getNotificationUploadVideo(notif: NSNotification) {
        if Configuration.selectedViewControllerName == String(self) {
            if let path = notif.object as? String {
                self.videoUrl = NSURL(fileURLWithPath: path)
                self.resultImage.thumbnailForVideoAtURL(self.videoUrl!)
            }
        }
    }
    
    deinit {
        pickerController.removeFromParentViewController()
        pickerController = nil
    }
    
    func setupPicker() {
        
        pickerController = NHDImagePickerController()
        
        let customDelegate = NHDCustomUIDelegate()
        pickerController.UIDelegate = customDelegate
        pickerController.defaultSelectedAssets = self.assets
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.isYouTubeVideo = false
            self.assets = assets
        }
        customDelegate.didDeSelectAssetsBlock = { [unowned self] (assets: [DKAsset]) in
            self.assets = nil
        }
        pickerController.assetType = .AllVideos
        pickerController.allowsLandscape = false
        pickerController.allowMultipleTypes = true
        pickerController.sourceType = .Photo
        pickerController.singleSelect = true

        addChildViewController(pickerController)
        pickerContainer.addSubview(pickerController.view)
        pickerController.didMoveToParentViewController(self)
        pickerController.view.snp_makeConstraints { (make) in
            make.edges.equalTo(pickerContainer)
        }
        MBProgressHUD.hideHUDForView(pickerContainer, animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // we selected a video
            self.videoUrl = videoUrl
            resultImage.thumbnailForVideoAtURL(videoUrl)
        }
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            resultImage.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func onCamera(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Recorder", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            navigationController?.presentViewController(vc, animated: true, completion: nil)
            Configuration.selectedViewControllerName = String(self)
        }
    }
    
    @IBAction func onYouTubeTapped(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "YouTube", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() as? NHDYouTubeSearchVideoVC {
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func uploadAction(sender: AnyObject) {
        
        let name = nameVideoTextField.text
        if name?.characters.count == 0 {
            Helper.showAlert("Warning", message: "Please enter the title of video", inViewController: self)
            return
        }
        guard let videoUrl = videoUrl else {
            Helper.showAlert("Warning", message: "Please select/recorde video to upload", inViewController: self)
            return
        }
        
        
        showLoading()
        let key = DataService.dataService.userRef.child("yourVideo").childByAutoId().key
        
        if isYouTubeVideo {
            
            let videoInfo: [String: AnyObject] = ["videoUrl": videoUrl.absoluteString, "name": self.nameVideoTextField.text!, "description": self.desTextField.text!]
            
            DataService.dataService.userRef.child("yourVideo").child(key).setValue(videoInfo)
            self.hideLoading()
            self.onBack()
        } else {
            FIRStorage.storage().reference().child("videos").child(key).putFile(videoUrl, metadata: nil, completion: { (metadata, error) in
                if error  != nil {
                    
                    Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                    self.hideLoading()
                } else {
                    if let videoUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let videoInfo: [String: AnyObject] = ["videoUrl": videoUrl, "name": self.nameVideoTextField.text!, "description": self.desTextField.text!]
                        
                        DataService.dataService.userRef.child("yourVideo").child(key).setValue(videoInfo)
                        self.hideLoading()
                        self.onBack()
                    }
                    
                }
            })
        }
        
        
        if let image = resultImage.image {
            DataService.uploadImage(image, key: key, complete: { (downloadURL) in
            }) { (error) in
                Helper.showAlert("Error", message: error.localizedDescription, inViewController: self)
                self.hideLoading()
            }
        }
        
    }
    
    @IBAction func chooseImageAction(sender: AnyObject) {
        
        if let videoUrl = videoUrl where isYouTubeVideo == false {
            
            NHDVideoPlayerViewController.showPlayer(videoUrl, orLink: nil, title: "Preview video before uploading", inViewController: self)
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
}

extension uploadVideoViewController: NHDYouTubeSearchVideoVCDelegate {
    
    func onChooseVideo(video: NHDYouTubeModel) {
        isYouTubeVideo = true
        resultImage.kf_setImageWithURL(NSURL(string: video.thumbnail))
        videoUrl = NSURL(string: video.videoURL)
        nameVideoTextField.text = video.title
        if let asset = assets?.first {
            pickerController.deselectAsset(asset)
        }
    }
}

class NHDImagePickerController: DKImagePickerController {
    
    internal override func done() {
        didSelectAssets?(assets: selectedAssets)
    }
}

class NHDCustomUIDelegate: CustomUIDelegate {
    
    var didDeSelectAssetsBlock: ((assets: [DKAsset]) -> Void)?

    override func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        
        didDeSelectAssetsBlock?(assets: didDeselectAssets)
    }
}