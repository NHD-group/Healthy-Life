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
                guard let value = snapshot.value as? NSDictionary else {
                    return
                }
                self.usernameLabel.text = value["username"] as? String
                if value["user_setting"] != nil {
                    
                    let islandRef = self.storageRef.child("images/\(self.chatter?.id as! String)")
                    self.avaImage.downloadImageWithImageReference(islandRef)
                    
                    
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

        usernameLabel.font = NHDFontBucket.blackFontWithSize(usernameLabel.font.pointSize)
        recentChatLabel.font = NHDFontBucket.italicFontWithSize(10)
    }


}
