//
//  TrainerDetailViewController.swift
//  HealthyLife
//
//  Created by admin on 8/19/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class DetailTrailer: NSObject {
  
    var videoUrl: String?
    var des: String?
    
    init(dictionary: NSDictionary ) {
    
        videoUrl = dictionary["videoUrl"] as? String
        des = dictionary["description"] as? String
        
    }
}

class TrainerDetailViewController: UIViewController {

    var trainerUid = String()
    
    @IBOutlet weak var avaImage: UIImageView!
    //done
    
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

        
        
        // Do any additional setup after loading the view.
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
    
    
       
}