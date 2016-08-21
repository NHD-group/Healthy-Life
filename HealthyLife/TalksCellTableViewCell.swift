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
    
    let storageRef = FIRStorage.storage().reference()
    
    
    var chatter: Chatter? {
        didSet {
            usernameLabel.text = chatter?.chatterName as? String
            
            contentView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            
            backview.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
            
            backview.layer.shadowOffset = CGSize(width: 0, height: 0)
            backview.layer.shadowOpacity = 0.8
            
            backview.layer.cornerRadius = 10
            backview.clipsToBounds = true
            
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
                
            }
        }
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        usernameLabel.font = NHDFontBucket.blackFontWithSize(usernameLabel.font.pointSize)
        recentChatLabel.font = NHDFontBucket.italicFontWithSize(10)
    }


}
