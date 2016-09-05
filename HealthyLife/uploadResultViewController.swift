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

class uploadResultViewController: uploadFoodViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Upload Result"
        desTextField.placeholder = "Current Weight"
        desTextField.keyboardType = .DecimalPad
    }
    
    override func updateImage(image: UIImage, text: String) {
        
        let ref =  FIRDatabase.database().reference()
        let currentUserID = DataService.currentUserID
        
        showLoading()
        let key =  ref.child("users").child(currentUserID!).child("results_journal").childByAutoId().key
        
        let newPost: Dictionary<String, AnyObject> = [
            "ImageUrl": key,
            "CurrentWeight": desTextField.text!,
            "Love": 0,
            "time": FIRServerValue.timestamp()
            
        ]
        
        ref.child("users").child(currentUserID!).child("results_journal").child(key).setValue(newPost)
        
        DataService.uploadImage(image, key: key, complete: { (downloadURL) in
            self.onBack()
            self.hideLoading()
        }) { (error) in
            Helper.showAlert("Error", message: error.localizedDescription, inViewController: self)
            self.hideLoading()
        }
    }
}
