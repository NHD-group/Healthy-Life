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

class AddDemoViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var desTextView: UITextView!
    
    var currentUid = (FIRAuth.auth()?.currentUser?.uid)!
    
    
    
    @IBOutlet weak var uploadStatusLabel: UILabel!
    @IBAction func uploadAction(sender: AnyObject) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        
        presentViewController(imagePickerController, animated: true, completion: nil)

    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // we selected a video
            
            let trailerRef = FIRDatabase.database().reference().child("videosTrailer").child(currentUid)
            
            let uploadTask = FIRStorage.storage().reference().child("videosTrailer").child(currentUid).putFile(videoUrl, metadata: nil, completion: { (metadata, error) in
                if error  != nil {
                    
                    return
                } else {
                    if let videoUrl = metadata?.downloadURL()?.absoluteString {
                        
                        
                        
                        let videoInfo: [String: AnyObject] = ["videoUrl": videoUrl, "description": self.desTextView.text!]
                        
                        trailerRef.setValue(videoInfo)
                    }
                    
                }
            })
            uploadTask.observeStatus(.Progress, handler: { (snapshot) in
                print(snapshot)
                if (snapshot.progress?.completedUnitCount) != nil{
                    self.uploadStatusLabel.text = "uploading"
                    //                    String(completedUnitCount)
                    
                }
                
            })
            
            uploadTask.observeStatus(.Success, handler: { (snapshot) in
                self.uploadStatusLabel.text = "done"
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
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
