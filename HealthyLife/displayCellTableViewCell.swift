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
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var weightView: UIView!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var loveImage: UIImageView!
    
    let storageRef = FIRStorage.storage().reference()
    var loveRef = FIRDatabaseReference()
    var ref =  FIRDatabase.database().reference()
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    
    
    var result: Result? {
        didSet {
            contentView.backgroundColor = Configuration.Colors.lightGray
            Configuration.Colors.lightGray
            
            backView.layer.cornerRadius = 10
            backView.clipsToBounds = true
            
            weightView.layer.cornerRadius = 10
            weightView.clipsToBounds = true


            ref.child("users").child(currentUserID!).child("user_setting").observeEventType(.Value, withBlock: { snapshot in
                if snapshot.value is NSNull {
                    self.weightChangedLabel.text = "0 kg"
                } else {
                    let dictionary = snapshot.value as! NSDictionary
                    
                    let startingWeight = dictionary["weight changed"] as! String
                    let currentWeight = self.result?.currentWeight
                    let weightChanged = Double(currentWeight!)! - Double(startingWeight)!
                    
                    if weightChanged > 0 {
                        self.weightView.backgroundColor = Configuration.Colors.limeGreen
                        self.weightChangedLabel.text = "gain: \(abs(weightChanged)) kg"
                    } else {
                        self.weightView.backgroundColor = Configuration.Colors.primary
                        self.weightChangedLabel.text = "lose: \(abs(weightChanged)) kg"
                    }
                }
                
            })
            
            let islandRef = storageRef.child("images/\(result!.resultKey)")
            avaImage.downloadImageWithImageReference(islandRef)
            
            timeLabel.text = "\(result!.time.timeAgo())"
            likeCountLabel.text = "\(result!.love)"
            
        }
    }
    
    
}
