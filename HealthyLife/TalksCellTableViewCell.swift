//
//  TalksCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class TalksCellTableViewCell: UITableViewCell {

    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var recentChatLabel: UILabel!
    
    let storageRef = FIRStorage.storage().reference()
    
    
    var chatter: Chatter? {
        didSet {
            usernameLabel.text = chatter?.chatterName as? String
            
            DataService.dataService.baseRef.child("users").child((chatter?.id)! as String).observeEventType(.Value, withBlock: { snapshot in
                let value = snapshot.value as! NSDictionary
                self.usernameLabel.text = value["username"] as? String
                if value["user_setting"] != nil {
                    
                    let islandRef = self.storageRef.child("images/\(self.chatter?.id as! String)")
                    
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
                    
                    
                    
                } else {
                    self.avaImage.image = UIImage(named: "defaults")
                    
                }
                
            })
            
            self.avaImage.layer.cornerRadius = self.avaImage.frame.size.width / 2
            self.avaImage.clipsToBounds = true
            
            self.avaImage.layer.borderWidth = 1.0
            self.avaImage.layer.borderColor = UIColor.blackColor().CGColor
            
            DataService.dataService.chats.child(chatter?.chatRoomKey as! String).queryLimitedToLast(1).observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
                
                let text = snapshot.value?["text"] as? String
                self.recentChatLabel.text = text
                
            }
        }
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
