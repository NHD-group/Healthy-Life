//
//  SettingViewController.swift
//  HealthyLife
//
//  Created by admin on 8/2/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate   {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var weightChangeLabel: UITextField!
    
    
    @IBOutlet weak var DOBLabel: UITextField!
    
    
    @IBOutlet weak var heightLabel: UITextField!
    
    let storageRef = FIRStorage.storage().reference()
    
    @IBAction func cancelKeyboardAction(sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    //MARK: Photo Action
    
    
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
        
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //MARK: save setting
    
    @IBAction func saveAction(sender: AnyObject) {
        
        let currentID = (FIRAuth.auth()?.currentUser?.uid)!
       
        
        let userSetting: Dictionary<String, AnyObject> = [
            "weight changed": weightChangeLabel.text!,
            "DOB": DOBLabel.text!,
            "height": heightLabel.text!
            
        ]
        DataService.dataService.userRef.child("user_setting").setValue(userSetting)
        
        //: Upload Image
        
        var avatarImage = imageView.image
        avatarImage = ResizeImage(avatarImage!, targetSize: CGSize(width: 100.0, height: 100.0))
        
        let imageData: NSData = UIImagePNGRepresentation(avatarImage!)!
        
        
        // Create a reference to the file you want to upload
        
        let riversRef = storageRef.child("images/\(currentID)")
        
        // Upload the file to the path ""images/\(key)"
        riversRef.putData(imageData, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
                
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
                print(downloadURL)
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let currentuserID = FIRAuth.auth()?.currentUser
        print(currentuserID)
        print("cascasdcdasdcsd")
        
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
