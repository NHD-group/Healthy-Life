//
//  uploadFoodViewController.swift
//  HealthyLife
//
//  Created by admin on 7/27/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class uploadFoodViewController:  BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var ref =  FIRDatabase.database().reference()
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    var key = ""
    
    @IBOutlet weak var FoodImageView: UIImageView!
    
    @IBAction func tapAction(sender: AnyObject) {
        view.endEditing(true)
        
    }
    //MARK: Set up camera and photo lib for uploading photos.
    
    @IBAction func cameraAction(sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)


    }
    
    
    @IBAction func photoLibAction(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        FoodImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK: Set Up action upload JSON data to firebase realtime database and Photo to Firebase Storage.
    
    @IBAction func uploadAction(sender: UIButton) {
        
        guard var foodImage = FoodImageView.image else {
            Helper.showAlert("Warning", message: "Please select a photo!", inViewController: self)
            return
        }
        
        //: Upload JSON to realtime database
        
        key =  ref.child("users").child(currentUserID!).child("food_journal").childByAutoId().key

        let newPost: Dictionary<String, AnyObject> = [
            "ImageUrl": key,
            "Description": foodDesTextField.text!,
            "Love": 0,
             "time": FIRServerValue.timestamp()
            
        ]

        ref.child("users").child(currentUserID!).child("food_journal").child(key).setValue(newPost)
        
        DataService.uploadImage(foodImage, key: key, complete: { (downloadURL) in
            self.onBack()
            }) { (error) in
                Helper.showAlert("Error", message: error.localizedDescription, inViewController: self)
        }
    
        
    }
    
     //******************************************************************************************************
    
    
    @IBOutlet weak var foodDesTextField: UITextField!
    
    @IBAction func cancelAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

}
