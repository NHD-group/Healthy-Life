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

class uploadFoodViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var desTextField: UITextField!
    
    var pickerController: DKImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Upload Food"
        MBProgressHUD.showHUDAddedTo(pickerContainer, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupPicker()
    }
    
    deinit {
        pickerController.removeFromParentViewController()
        pickerController = nil
    }
    
    func setupPicker() {
        
        pickerController = DKImagePickerController()
        pickerController.UIDelegate = CustomUIDelegate()
        pickerController.assetType = .AllPhotos
        pickerController.allowsLandscape = false
        pickerController.allowMultipleTypes = true
        pickerController.sourceType = .Both
        pickerController.singleSelect = true
        
        addChildViewController(pickerController)
        pickerContainer.addSubview(pickerController.view)
        pickerController.didMoveToParentViewController(self)
        pickerController.view.snp_makeConstraints { (make) in
            make.edges.equalTo(pickerContainer)
        }
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
            self.dismissKeyboard()
            self.updateImage(image, text: self.desTextField.text!)
        }
        
        
    }
    
    func updateImage(image: UIImage, text: String) {
        
        let ref =  FIRDatabase.database().reference()
        let currentUserID = DataService.currentUserID
        
        showLoading()
        let key =  ref.child("users").child(currentUserID).child("food_journal").childByAutoId().key
        
        let newPost: Dictionary<String, AnyObject> = [
            "ImageUrl": key,
            "Description": text,
            "Love": 0,
            "time": FIRServerValue.timestamp()
        ]
        
        ref.child("users").child(currentUserID).child("food_journal").child(key).setValue(newPost)
        
        DataService.uploadImage(image, key: key, complete: { (downloadURL) in
            self.onBack()
            self.hideLoading()
        }) { (error) in
            Helper.showAlert("Error", message: error.localizedDescription, inViewController: self)
            self.hideLoading()
        }
    }

}
