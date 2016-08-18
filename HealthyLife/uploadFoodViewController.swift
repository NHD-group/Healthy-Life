//
//  uploadFoodViewController.swift
//  HealthyLife
//
//  Created by admin on 7/27/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class uploadFoodViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref =  FIRDatabase.database().reference()
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    var key = ""
    let storageRef = FIRStorage.storage().reference()
    
    
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
        
        //: Upload JSON to realtime database
        
        key =  ref.child("users").child(currentUserID!).child("food_journal").childByAutoId().key

        let newPost: Dictionary<String, AnyObject> = [
            "ImageUrl": key,
            "Description": foodDesTextField.text!,
            "Love": 0,
             "time": FIRServerValue.timestamp()
            
        ]

        ref.child("users").child(currentUserID!).child("food_journal").child(key).setValue(newPost)
        
        
        
        //: Upload Image 
        
        var foodImage = FoodImageView.image
        foodImage = foodImage?.resizeImage(CGSize(width: 500.0, height: 500.0))
        
        let imageData: NSData = UIImagePNGRepresentation(foodImage!)!

        
        
        
        // Create a reference to the file you want to upload
        
        let riversRef = storageRef.child("images/\(key)")
        
        // Upload the file to the path ""images/\(key)"
        riversRef.putData(imageData, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
                
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
                print(downloadURL)
                print("does it work")
                
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
     //******************************************************************************************************
    
    
    @IBOutlet weak var foodDesTextField: UITextField!
    
    @IBAction func cancelAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
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
