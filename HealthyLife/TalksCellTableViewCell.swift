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
    
    @IBOutlet weak var backview: UIView!
    var badgeLabel: UILabel?
    let storageRef = FIRStorage.storage().reference()
    
    
    var chatter: Chatter? {
        didSet {
            usernameLabel.text = chatter?.chatterName
            
            
            guard let chatterID = chatter?.id else {
                return
            }
            DataService.dataService.baseRef.child("users").child(chatterID).observeEventType(.Value, withBlock: { snapshot in
                guard let value = snapshot.value as? NSDictionary else {
                    return
                }
                self.usernameLabel.text = value["username"] as? String
                if value["user_setting"] != nil {
                    
                    let islandRef = self.storageRef.child("images/\(chatterID)")
                    self.avaImage.downloadImageWithImageReference(islandRef)
                    
                    
                } else {
                    self.avaImage.image = UIImage(named: "defaults")
                    
                }
                
            })
            
            self.avaImage.layer.cornerRadius = self.avaImage.frame.size.width / 2
            self.avaImage.clipsToBounds = true
            
            self.avaImage.layer.borderWidth = 1.0
            self.avaImage.layer.borderColor = UIColor.blackColor().CGColor
            
            self.recentChatLabel.text = "<No Message. Start to chat now!>"
            DataService.dataService.chats.child((chatter?.chatRoomKey)!).queryLimitedToLast(1).observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
                
                guard let value = snapshot.value else {
                    return
                }
                
                var type = ""
                var text = value["text"] as? String
                if let Type = value["type"] as? String {
                    type = Type
                }
                
                if type == Message.MessageType.Photo.rawValue {
                    text = "[Photo sent]"
                } else if type == Message.MessageType.Video.rawValue {
                    text = "[Video sent]"
                }
                
                self.recentChatLabel.text = text
                
                DataService.dataService.baseRef.child("users").child(DataService.currentUserID).child("chatRoom").child((self.chatter?.chatterName)!).child("unreadMessage").observeEventType(.Value, withBlock: { snapshot in
                    
                    var count = 0
                    if let value = snapshot.value as? Int {
                        count = value
                    }
                    
                    if count > 0 {
                        self.badgeLabel?.hidden = false
                        self.badgeLabel?.text = String(count)
                    } else {
                        self.badgeLabel?.hidden = true
                    }
                })
            }
        }
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        usernameLabel.font = NHDFontBucket.blackFontWithSize(usernameLabel.font.pointSize)
        recentChatLabel.font = NHDFontBucket.italicFontWithSize(10)
        
        contentView.backgroundColor = Configuration.Colors.lightGray
        backview.layer.cornerRadius = 10
        backview.clipsToBounds = true
//        backview.layer.shadowOpacity = 0.3
//        backview.layer.shadowPath = UIBezierPath(rect: backview.layer.bounds).CGPath
        
        let label = UILabel(frame: CGRectMake(2, 2, 20, 20))
        label.font = NHDFontBucket.boldFontWithSize(12)
        label.hidden = true
        label.text = "0"
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
        label.backgroundColor = Configuration.Colors.primary
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        self.addSubview(label)
        
        self.badgeLabel = label
    }


}
