//
//  AddDemoViewController.swift
//  HealthyLife
//
//  Created by admin on 8/18/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class AddDemoViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var priceTextField: UITextField!
    
    var videoUrl = NSURL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func uploadAction(sender: AnyObject) {
        
        showLoading()
        let currentUid = DataService.currentUserID
        let trailerRef = FIRDatabase.database().reference().child("videosTrailer").child(currentUid)
        
        FIRStorage.storage().reference().child("videosTrailer").child(currentUid).putFile(videoUrl, metadata: nil, completion: { (metadata, error) in
            if error  != nil {
                
                Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                self.hideLoading()
                return
            } else {
                var thumbNail = self.thumbnailImage.image
                thumbNail = thumbNail!.resizeImage(Configuration.defaultPhotoSize)
                
                let imageData: NSData = UIImageJPEGRepresentation(thumbNail!, Configuration.compressionQuality)!

                
                // Create a reference to the file you want to upload
                
                let riversRef = FIRStorage.storage().reference().child("images").child("trailer").child(currentUid)
                
                // Upload the file to the path ""images/\(key)"
                riversRef.putData(imageData, metadata: nil) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                        Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                        self.hideLoading()
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        if let downloadURL = metadata?.downloadURL()?.absoluteString {
                            trailerRef.child("thumbnail").setValue(downloadURL)
                            
                        }
                        
                        self.hideLoading()
                        self.onBack()
                       
                        
                    }
                }
                
                if let videoUrl = metadata?.downloadURL()?.absoluteString {
                    
                    let videoInfo: [String: AnyObject] = ["videoUrl": videoUrl, "description": self.desTextView.text!, "pricePerWeek": self.priceTextField.text!]
                    
                    trailerRef.setValue(videoInfo)
                    FIRDatabase.database().reference().child("users").child(currentUid).child("demo").setValue(true)
                    trailerRef.child("priceList").childByAutoId().setValue(self.priceTextField.text!)
                    
                }
                
            }
        })
    
    }

    
    @IBAction func chooseVideoAction(sender: AnyObject) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // we selected a video
            
            self.videoUrl = videoUrl
              thumbnailImage.thumbnailForVideoAtURL(videoUrl)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
}
