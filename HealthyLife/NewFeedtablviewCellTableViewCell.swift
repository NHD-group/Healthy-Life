//
//  NewFeedtablviewCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/4/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class NewFeedtablviewCellTableViewCell: UITableViewCell {
    
    let storageRef = FIRStorage.storage().reference()
    var islandRef = FIRStorageReference()
    let defaults = NSUserDefaults.standardUserDefaults()
    var followedRef = FIRDatabaseReference()
    var followerRef = FIRDatabaseReference()
    var userProfile: UserProfile!
    var selectedUID: String!
    var currentUID = DataService.currentUserID
    var chatKey = String()
    var sellectedUsername = String()
    
    
    
    
   
    var currentUserName = String()
    
    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var talkButton: UIButton!
    
    @IBOutlet weak var HeightLabel: UILabel!
    @IBOutlet weak var weightChangedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var DOBLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var followImage: UIImageView!
    
    
   
    func configureCell(userProfile: UserProfile, setImage: String ) {
        
        self.userProfile = userProfile
        selectedUID = setImage
        self.currentUserName = self.defaults.valueForKey("currentUserName") as! String
        
        sellectedUsername = userProfile.username as! String

        
        
        //MARK: set up labels
        
        HeightLabel.text = userProfile.userSetting?.height as? String
        weightChangedLabel.text = userProfile.userSetting?.weightChanged as? String
        DOBLabel.text = userProfile.userSetting?.DOB  as? String
        nameLabel.text = sellectedUsername
        followerCountLabel.text = "\(userProfile.followerCount!) followers"
        
        
        //MARK: Set up ava Image
        
        if userProfile.userSetting == nil {
            avaImage.image = UIImage(named: "defaults_icon")
    
        } else {
            
            islandRef  = storageRef.child("images/\(setImage)")
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.dataWithMaxSize((1 * 1024 * 1024)/2) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    print("it workss")
                    let AvaImage: UIImage! = UIImage(data: data!)
                    self.avaImage.image = AvaImage
                    
                    
                    
                }
            }
        }
        
        self.avaImage.layer.cornerRadius = 20
        self.avaImage.clipsToBounds = true
        
        
        //******************************
        
        followedRef = DataService.dataService.userRef.child("followed").child(setImage)
        
        
        followedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let thumbsUpDown = snapshot.value as? NSNull {
                
                // Current user hasn't voted for the joke... yet.
                
                print(thumbsUpDown)
                self.followImage.image = UIImage(named: "add")
                
            } else {
                
                // Current user voted for the joke!
                
                self.followImage.image = UIImage(named: "added")
                
            }
            
        })
        
        
        DataService.dataService.chatRoom.child(sellectedUsername).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let checkRoom = snapshot.value as? NSNull {
                self.chatKey =  self.selectedUID + self.currentUID
            } else {
                let dictinary = snapshot.value as? NSDictionary
                self.chatKey = dictinary!["chatRoomKey"] as! String
                print(self.chatKey)
                print("check chatKey")
            }
        })

    }
    
    
    
    @IBAction func talkAction(sender: AnyObject) {
       DataService.dataService.chatRoom.child(userProfile.username as! String).observeSingleEventOfType(.Value, withBlock: { snapshot in
        if let checkRoom = snapshot.value as? NSNull {
            
            DataService.dataService.chatRoom.child(self.sellectedUsername).setValue(["chatRoomKey": self.chatKey])
            DataService.dataService.baseRef.child("users").child(self.selectedUID).child("chatRoom").child(self.currentUserName).setValue(["chatRoomKey": self.chatKey])

        }
        
        
        })
        
        
    }
    
    
    func followTapped(sender: UITapGestureRecognizer) {
        
        followedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let thumbsUpDown = snapshot.value as? NSNull {
                print(thumbsUpDown)
                self.followImage.image = UIImage(named: "add")
                
                                
                
                self.followerRef =   DataService.dataService.baseRef.child("users").child(self.selectedUID).child("follower").child(self.currentUID)
                
                self.followerRef.child("name").setValue( self.currentUserName)
                self.followedRef.child("name").setValue(self.currentUserName)
               
                self.userProfile.addSubTractFollower(true)

                // setValue saves the vote as true for the current user.
                // voteRef is a reference to the user's "votes" path.
                
                
            } else {
                self.followImage.image = UIImage(named: "added")
                
                self.followedRef.removeValue()
                self.followerRef.removeValue()
                
                self.userProfile.addSubTractFollower(false)
                
                
                
            }
            
        })
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(NewFeedtablviewCellTableViewCell.followTapped(_:)))
        tap.numberOfTapsRequired = 1
        followImage.addGestureRecognizer(tap)
        followImage.userInteractionEnabled = true
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
