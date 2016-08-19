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
    var currentUserName = DataService.currentUserName
    
    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var talkButton: UIButton!
    
    @IBOutlet weak var HeightLabel: UILabel!
   
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var averageStarLabel: UILabel!
    
    @IBOutlet weak var amountPeopleVotedLabel: UILabel!
    @IBOutlet weak var commentsButton: UIButton!
    
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var followImage: UIImageView!
    
    
   
    func configureCell(userProfile: UserProfile, setImage: String) {
        
        self.userProfile = userProfile
        selectedUID = setImage
        sellectedUsername = userProfile.username!
        
        
        self.avaImage.layer.cornerRadius = self.avaImage.frame.size.width / 2
        self.avaImage.clipsToBounds = true
        
        self.avaImage.layer.borderWidth = 1.0
        self.avaImage.layer.borderColor = UIColor.blackColor().CGColor
        
        
        //MARK: set up labels
        

        let totalPeopleVoted = userProfile.totalPeopleVoted ?? 0
        if totalPeopleVoted != 0 {
            averageStarLabel.text = "\(userProfile.totalStar!/totalPeopleVoted)"

        } else {
            averageStarLabel.text = "0"
            
        }
        
        let commentsCount = userProfile.userCommentCount ?? 0
        commentsButton.setTitle("\(commentsCount) comments", forState: .Normal)
       
        
        HeightLabel.text = userProfile.userSetting?.height as? String
       
        nameLabel.text = sellectedUsername
        followerCountLabel.text = "\(userProfile.followerCount!) followers"
        amountPeopleVotedLabel.text = "\(totalPeopleVoted) voted"
        //MARK: Set up ava Image
        
        if userProfile.userSetting == nil {
            avaImage.image = UIImage(named: "defaults")
            
        } else {
            islandRef  = storageRef.child("images/\(setImage)")
            avaImage.downloadImageWithImageReference(islandRef)
        }
        
        
        
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
            if let dictinary = snapshot.value as? NSDictionary {
                self.chatKey = dictinary["chatRoomKey"] as! String
                print(self.chatKey)
                print("check chatKey")
            } else {
                self.chatKey =  self.selectedUID + self.currentUID
            }
        })
        
    }
    
    
    
    @IBAction func talkAction(sender: AnyObject) {
        DataService.dataService.chatRoom.child(userProfile.username!).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                
                DataService.dataService.chatRoom.child(self.sellectedUsername).setValue(["chatRoomKey": self.chatKey, "id": self.selectedUID])
                DataService.dataService.baseRef.child("users").child(self.selectedUID).child("chatRoom").child(self.currentUserName).setValue(["chatRoomKey": self.chatKey, "id": self.currentUID])
                
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
