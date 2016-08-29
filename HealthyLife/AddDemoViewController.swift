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

class AddDemoViewController: BaseViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var desTextView: UITextView!
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    
    var currentUid = (FIRAuth.auth()?.currentUser?.uid)!
    var videoUrl = NSURL()
    
    
    @IBOutlet weak var priceTextField: UITextField!
    
    
    @IBAction func uploadAction(sender: AnyObject) {
        
        showLoading()

        let trailerRef = FIRDatabase.database().reference().child("videosTrailer").child(currentUid)
        
        let uploadTask = FIRStorage.storage().reference().child("videosTrailer").child(currentUid).putFile(videoUrl, metadata: nil, completion: { (metadata, error) in
            if error  != nil {
                
                Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                return
            } else {
                var thumbNail = self.thumbnailImage.image
                thumbNail = thumbNail!.resizeImage(CGSize(width: 500.0, height: 500.0))
                
                let imageData: NSData = UIImagePNGRepresentation(thumbNail!)!
                
                
                
                
                // Create a reference to the file you want to upload
                
                let riversRef = FIRStorage.storage().reference().child("images").child("trailer").child(self.currentUid)
                
                // Upload the file to the path ""images/\(key)"
                riversRef.putData(imageData, metadata: nil) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                        Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
