//
//  uploadFoodViewController.swift
//  HealthyLife
//
//  Created by admin on 7/27/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import DKImagePickerController
import MBProgressHUD

class uploadFoodViewController:  BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var desTextField: UITextField!
    
    var pickerController: DKImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Upload Food"
        addBackgroundImage()
        setupPicker()
    }
    
    func setupPicker() {
        
        if pickerController != nil {
            return
        }
        
        pickerController = DKImagePickerController()
        
        // Custom camera
        pickerController.UIDelegate = CustomUIDelegate()
        
        pickerController.assetType = .AllPhotos
        pickerController.allowsLandscape = false
        pickerController.allowMultipleTypes = true
        pickerController.sourceType = .Both
        pickerController.singleSelect = true
        
        //		pickerController.showsCancelButton = true
        //		pickerController.showsEmptyAlbums = false
        //		pickerController.defaultAssetGroup = PHAssetCollectionSubtype.SmartAlbumFavorites
        
        // Clear all the selected assets if you used the picker controller as a single instance.
        //		pickerController.defaultSelectedAssets = nil
        
        MBProgressHUD.showHUDAddedTo(pickerContainer, animated: true)
        
        addChildViewController(pickerController)
        pickerContainer.addSubview(pickerController.view)
        pickerController.didMoveToParentViewController(self)
        MBProgressHUD.hideHUDForView(pickerContainer, animated: true)

    }
    
    @IBAction func uploadAction(sender: UIButton) {
        
        guard let asset = pickerController.selectedAssets.first else {
            Helper.showAlert("Warning", message: "Please select a photo!", inViewController: self)
            return
        }
        
        guard desTextField.text?.characters.count > 0 else {
            Helper.showAlert("Warning", message: "Please enter the title!", inViewController: self)
            return
        }
        
        asset.fetchImageWithSize(Configuration.defaultPhotoSize) { (image, info) in
            guard let image = image else {
                Helper.showAlert("Error", message: info?.description, inViewController: self)
                return
            }
            
            let ref =  FIRDatabase.database().reference()
            let currentUserID = DataService.currentUserID
            
            self.showLoading()
            let key =  ref.child("users").child(currentUserID).child("food_journal").childByAutoId().key
            
            let newPost: Dictionary<String, AnyObject> = [
                "ImageUrl": key,
                "Description": self.desTextField.text!,
                "Love": 0,
                "time": FIRServerValue.timestamp()
                
            ]
            
            ref.child("users").child(currentUserID).child("food_journal").child(key).setValue(newPost)
            
            DataService.uploadImage(image, key: key, complete: { (downloadURL) in
                self.onBack()
                self.hideLoading()
            }) { (error) in
                Helper.showAlert("Error", message: error.localizedDescription, inViewController: self)
            }
        }
        
    }

}
