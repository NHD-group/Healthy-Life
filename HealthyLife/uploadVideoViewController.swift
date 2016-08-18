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

class uploadVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

   
    
    @IBOutlet weak var nameVideoTextField: UITextField!
    
    @IBOutlet weak var libImagesButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var desTextField: UITextField!
    
    
    @IBOutlet weak var uploadStatusLabel: UILabel!
    
    @IBAction func chooseImageAction(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    var videoUrl = NSURL()
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // we selected a video
            self.videoUrl = videoUrl
            libImagesButton.hidden = true
            cameraButton.hidden = true
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func uploadAction(sender: AnyObject) {
        
        let key = DataService.dataService.userRef.child("yourVideo").childByAutoId().key
        
        let uploadTask = FIRStorage.storage().reference().child("videos").child(key).putFile(videoUrl, metadata: nil, completion: { (metadata, error) in
            if error  != nil {
                
                return
            } else {
                if let videoUrl = metadata?.downloadURL()?.absoluteString {
                    
                    
<<<<<<< HEAD
=======
                }
            })
            uploadTask.observeStatus(.Progress, handler: { (snapshot) in
                print(snapshot)
                if (snapshot.progress?.completedUnitCount) != nil{
                    self.uploadStatusLabel.text = "uploading"
                    //                    String(completedUnitCount)
>>>>>>> origin/master
                    
                    let videoInfo: [String: AnyObject] = ["videoUrl": videoUrl, "name": self.nameVideoTextField.text!, "description": self.desTextField.text!]
                    
                    DataService.dataService.userRef.child("yourVideo").child(key).setValue(videoInfo)
                }
                
            }
        })
        uploadTask.observeStatus(.Progress, handler: { (snapshot) in
            print(snapshot)
            if let completedUnitCount = snapshot.progress?.completedUnitCount{
                self.uploadStatusLabel.text = "uploading"
                //                    String(completedUnitCount)
                
            }
            
        })
        
        uploadTask.observeStatus(.Success, handler: { (snapshot) in
            self.uploadStatusLabel.text = "done"
        })

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

