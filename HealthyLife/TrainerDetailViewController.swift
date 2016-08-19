//
//  TrainerDetailViewController.swift
//  HealthyLife
//
//  Created by admin on 8/19/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import AVKit

class DetailTrailer: NSObject {
  
    var videoUrl: String?
    var des: String?
    var thumbNailUrl: String?
    
    
    init(dictionary: NSDictionary ) {
    
        videoUrl = dictionary["videoUrl"] as? String
        des = dictionary["description"] as? String
        thumbNailUrl = dictionary["thumbnail"] as? String
        
    }
}

class TrainerDetailViewController: UIViewController {

    var trainerUid = String()
    
    @IBOutlet weak var avaImage: UIImageView!
    //done
    
    @IBOutlet weak var blurrView: UIVisualEffectView!
    
    
    @IBOutlet weak var averageVote: UILabel!
    //done
    
    @IBOutlet weak var amoutVotes: UILabel!
    //done
    
    @IBOutlet weak var commentCountButton: UIButton!
    //done
    
    @IBOutlet weak var desTextView: UITextView!
    //done
    
    @IBOutlet weak var usernameLabel: UILabel!
    //done
    
    @IBOutlet weak var thumbnailUrl: UIImageView!
    
    
    @IBOutlet weak var talkButton: UIButton!
    
    @IBOutlet weak var getHealthyButton: UIButton!
    
    @IBAction func videoTrailerAction(sender: AnyObject) {
        
        
    }
    
    
    var Detailtrailer: DetailTrailer!
    var uid = String()
    var videoUrl = NSURL()
    let storageRef = FIRStorage.storage().reference()
    
    var currentUid = (FIRAuth.auth()?.currentUser?.uid)!
    var currentUserName = String()
    
    var selectedUid = String()
    var selectedUsername = String()
    
    var chatKey = String()
    
    let ref = FIRDatabase.database().reference()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        
        ref.child("videosTrailer").child(trainerUid).observeEventType(.Value, withBlock: { snapshot in
            let value = snapshot.value as! NSDictionary
            let detailTrailer = DetailTrailer(dictionary: value)
            
          
           self.configureCell(detailTrailer)
        
        })
        
        
        let islandRef = storageRef.child("images/trailer/\(currentUid)")
        thumbnailUrl.downloadImageWithImageReference(islandRef)

        self.blurrView.layer.cornerRadius = self.avaImage.frame.size.width / 2
        self.blurrView.clipsToBounds = true
        
        self.thumbnailUrl.layer.cornerRadius = 10
        self.thumbnailUrl.clipsToBounds = true


      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    func configureCell(demo : DetailTrailer ) {
        Detailtrailer = demo
        
        currentUserName = NSUserDefaults.standardUserDefaults().valueForKey("currentUserName") as! String
        
        let url = NSURL(string: Detailtrailer.videoUrl!)
        videoUrl = url!
        
        
        uid = trainerUid
        selectedUid = trainerUid
        
        desTextView.text = Detailtrailer.des!
        
        
        // profile
        
        
        ref.child("users").child(uid).observeEventType(.Value, withBlock: { snapshot in
            let userProfile = UserProfile(key: snapshot.key , dictionary: snapshot.value as! NSDictionary)
            
            self.selectedUsername = userProfile.username!
            
            
            //average Rate
            if userProfile.totalPeopleVoted != 0 {
                self.averageVote.text = "\(userProfile.totalStar!/userProfile.totalPeopleVoted!)"
                
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
        
        DataService.dataService.baseRef.child("users").child(uid).child("trainee").child(currentUid).child("name").setValue( self.currentUserName)
        
        
        
    }
    
    
    @IBAction func talkAction(sender: AnyObject) {
        DataService.dataService.chatRoom.child(selectedUsername).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                
                DataService.dataService.chatRoom.child(self.selectedUsername).setValue(["chatRoomKey": self.chatKey, "id": self.selectedUid])
                DataService.dataService.baseRef.child("users").child(self.selectedUid).child("chatRoom").child(self.currentUserName).setValue(["chatRoomKey": self.chatKey, "id": self.currentUid])
                
            }
            
            
        })
        
    }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
//        trainerComment
        
        
        if segue.identifier == "player" {
            
            let destination = segue.destinationViewController as! AVPlayerViewController
            destination.player = AVPlayer(URL: videoUrl)

          
        } else if segue.identifier == "trainerComment" {
            let controller = segue.destinationViewController as! commentsViewController
           
                controller.KeyUid = uid
            
        } else if segue.identifier == "talk" {
            
            
            let DestViewController = segue.destinationViewController as! UINavigationController
            let controller = DestViewController.topViewController as! chatViewController
            
            
            
                controller.senderId =  currentUid
                controller.senderDisplayName = currentUserName
                controller.chatKey = chatKey
                controller.chatRoomTittle = selectedUsername
            
        }

    }
    
    
    
    
}