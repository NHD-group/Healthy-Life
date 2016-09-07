//
//  SettingViewController.swift
//  HealthyLife
//
//  Created by admin on 8/2/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate   {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var weightChangeLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var heightLabel: UITextField!
    var userSetting: UserSetting?

    @IBAction func cameraAction(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func photoLibAction(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismissViewControllerAnimated(true, completion: nil)
        imageView.tag = 100
    }
    
    
    @IBAction func saveAction(sender: AnyObject) {
        
        let userSetting: Dictionary<String, AnyObject> = [
            "weight changed": weightChangeLabel.text!,
            "DOB": Helper.getPresentationDateString(datePicker.date),
            "height": heightLabel.text!
        ]
        DataService.dataService.userRef.child("user_setting").setValue(userSetting)
        
        //: Upload Image
        if imageView.tag == 0 {
            onBack()
            return
        }
        
        showLoading()
        imageView.uploadImageWithKey(DataService.currentUserID, complete: { (downloadURL) in
            DataService.dataService.userRef.child("photoURL").setValue(downloadURL)
            self.hideLoading()
            self.onBack()
            }) { (error) in
                Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                self.hideLoading()

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        imageView.downloadImageWithKey(DataService.currentUserID)
        if let userSetting = userSetting {
            if let date = Helper.setPresentationDateString(userSetting.DOB) {
                datePicker.date = date
            }
            weightChangeLabel.text = userSetting.weightChanged
            heightLabel.text = userSetting.height
        }
        DataService.dataService.userRef.child("photoURL").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let photoURL = snapshot.value as? String {
                self.imageView.kf_setImageWithURL(NSURL(string: photoURL))
            }
        })
    }
}
