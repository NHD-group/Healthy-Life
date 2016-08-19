//
//  displayCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/19/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class displayCellTableViewCell: UITableViewCell {

    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var weightChangedLabel: UILabel!
    
    @IBOutlet weak var loveImage: UIImageView!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    let storageRef = FIRStorage.storage().reference()
    var loveRef = FIRDatabaseReference()
    var ref =  FIRDatabase.database().reference()
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    
    
    var result: Result? {
        didSet {
            ref.child("users").child(currentUserID!).child("user_setting").observeEventType(.Value, withBlock: { snapshot in
                if snapshot.value == nil {
                    self.weightChangedLabel.text = "0 kg"
                } else {
                    let dictionary = snapshot.value as! NSDictionary
                    
                    let startingWeight = dictionary["weight changed"] as! String
                    let currentWeight = self.result?.currentWeight
                    var weightChanged = Double(currentWeight!)! - Double(startingWeight)!
                    
                    if weightChanged > 0 {
                        self.weightChangedLabel.text = "gain: \(abs(weightChanged)) kg"
                    } else {
                        self.weightChangedLabel.text = "lose: \(abs(weightChanged)) kg"
                    }
                    
                    
                }
                
            })
            
            let islandRef = storageRef.child("images/\(result!.resultKey)")
            avaImage.downloadImageWithImageReference(islandRef)

            
            
            timeLabel.text = "\(result!.time.timeAgo())"
            likeCountLabel.text = "\(result?.love)"
            
            
          
            
            
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // UITapGestureRecognizer is set programatically.
          }
    
    
}
