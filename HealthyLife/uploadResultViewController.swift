//
//  uploadResultViewController.swift
//  HealthyLife
//
//  Created by admin on 8/18/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase

class uploadResultViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var ref =  FIRDatabase.database().reference()
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    var key = ""
    let storageRef = FIRStorage.storage().reference()

    @IBOutlet weak var currentWeightLabel: UITextField!

    @IBOutlet weak var resultImage: UIImageView!
    
    
    @IBAction func cameraAction(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func libAction(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        resultImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    @IBAction func uploadAction(sender: AnyObject) {
        key =  ref.child("users").child(currentUserID!).child("results_journal").childByAutoId().key
        
        let newPost: Dictionary<String, AnyObject> = [
            "ImageUrl": key,
            "CurrentWeight": currentWeightLabel.text!,
            "Love": 0,
            "time": FIRServerValue.timestamp()
            
        ]
        
        ref.child("users").child(currentUserID!).child("results_journal").child(key).setValue(newPost)
        
        
        
        //: Upload Image
        showLoading()
        var foodImage = resultImage.image
        foodImage = foodImage?.resizeImage(CGSize(width: 500.0, height: 500.0))
        
        let imageData: NSData = UIImagePNGRepresentation(foodImage!)!
        let riversRef = storageRef.child("images/\(key)")
        riversRef.putData(imageData, metadata: nil) { metadata, error in
            if (error != nil) {
                self.hideLoading()
                Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
            } else {
                self.hideLoading()
                self.onBack()
            }
        }
        
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
