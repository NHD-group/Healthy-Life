//
//  demoTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 7/31/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import AVKit

class demoTableViewCell: UITableViewCell {

    @IBOutlet weak var avaImage: UIImageView!
    //done
    
    @IBOutlet weak var averageVote: UILabel!
    //done
    
    @IBOutlet weak var amoutVotes: UILabel!
    //done

    @IBOutlet weak var commentCountButton: UIButton!
    //done
    
    @IBOutlet weak var desLabel: UILabel!
   
    
    @IBOutlet weak var usernameLabel: UILabel!
    //done
    
    @IBOutlet weak var backview: UIView!

    
    @IBOutlet weak var talkButton: UIButton!
    
    @IBOutlet weak var getHealthyButton: UIButton!
    
    @IBAction func videoTrailerAction(sender: AnyObject) {
      
       
    }
    
    var trailer: Trailer!
    var uid = String()
    var videoUrl = NSURL()
    let storageRef = FIRStorage.storage().reference()
    
    var currentUid = (FIRAuth.auth()?.currentUser?.uid)!
    var currentUserName = String()
    
    var selectedUid = String()
    var selectedUsername = String()
    
    var chatKey = String()
 

    
    func configureCell(demo : Trailer ) {
        trailer = demo
        
        currentUserName = NSUserDefaults.standardUserDefaults().valueForKey("currentUserName") as! String
        
        let url = NSURL(string: trailer.videoUrl!)
        videoUrl = url!
        uid = trailer.uid!
        selectedUid = trailer.uid!
        
        desLabel.text = trailer.des!
        
        contentView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        
        backview.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
        
        backview.layer.shadowOffset = CGSize(width: 0, height: 0)
        backview.layer.shadowOpacity = 0.8
        
        backview.layer.cornerRadius = 10
        backview.clipsToBounds = true
        

        
        
        // profile
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).observeEventType(.Value, withBlock: { snapshot in
            
            guard let dictionary = snapshot.value as? NSDictionary else {
                return
            }
            
            let userProfile = UserProfile(key: snapshot.key , dictionary: dictionary)
            
            self.selectedUsername = userProfile.username!
            
            
            //average Rate
            if userProfile.totalPeopleVoted != 0 {
                self.averageVote.text = "\(Double(userProfile.totalStar!)/Double(userProfile.totalPeopleVoted!))"
                
            } else {
                self.averageVote.text = "0"
                
            }
            //set up button display
            
            //talk
            self.talkButton.layer.cornerRadius = 10
            self.talkButton.clipsToBounds = true
            
            //get Healthy
            self.getHealthyButton.layer.cornerRadius = 10
            self.getHealthyButton.clipsToBounds = true
            
            //amount Vote
            
            self.amoutVotes.text = "\(userProfile.totalPeopleVoted!) votes"
            
            // Button count
            
            self.commentCountButton.setTitle("\(userProfile.userCommentCount!) comments", forState: .Normal)
            
            //Username
            
            self.usernameLabel.text = userProfile.username!
            
            //avaImage
            
            self.avaImage.layer.borderWidth = 1.0
            self.avaImage.layer.borderColor = UIColor.blackColor().CGColor
            
            if userProfile.userSetting == nil {
                self.avaImage.image = UIImage(named: "defaults")
                
            } else {
                
                let islandRef  = self.storageRef.child("images/\(self.uid)")
                self.avaImage.downloadImageWithImageReference(islandRef)
            }
            
            
            DataService.dataService.chatRoom.child(self.selectedUsername).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let dictinary = snapshot.value as? NSDictionary {
                    self.chatKey = dictinary["chatRoomKey"] as! String
                    print(self.chatKey)
                    print("check chatKey")
                } else {
                    self.chatKey =  self.selectedUid + self.currentUid
                }
            })

            
        })
        


        
       
    }
    
    
    @IBAction func getHealthyAction(sender: AnyObject) {
        alertMessage()
             
 
        
    }
    
    weak var navigationController: UINavigationController?
    
    
    func alertMessage() {
        let alert = UIAlertController(title: "Sign Up To This Trainer", message: "Pleas ask your trainers for new workoutplan", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "ok", style: .Default) { (UIAlertAction) in
            DataService.dataService.baseRef.child("users").child(self.uid).child("trainee").child(self.currentUid).child("name").setValue( self.currentUserName)
            
        }
        
        let alertActionCancel = UIAlertAction(title: "cancel", style: .Default, handler: nil)
        
        alert.addAction(alertAction)
        alert.addAction(alertActionCancel)
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    

    
    
    @IBAction func talkAction(sender: AnyObject) {
        DataService.dataService.chatRoom.child(selectedUsername).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                
                DataService.dataService.chatRoom.child(self.selectedUsername).setValue(["chatRoomKey": self.chatKey, "id": self.selectedUid])
                DataService.dataService.baseRef.child("users").child(self.selectedUid).child("chatRoom").child(self.currentUserName).setValue(["chatRoomKey": self.chatKey, "id": self.currentUid, "unreadMessage" : 0])
                
            }
            
            
        })

    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
