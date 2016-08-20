//
//  Message.swift
//  HealthyLife
//
//  Created by Dinh Quang Hieu on 8/17/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class Message: NSObject {
    
    enum MessageType: String {
        case Text = "TEXT"
        case Photo = "PHOTO"
        case Audio = "AUDIO"
        case Video = "VIDEO"
        
        func isText() -> Bool {
            return self == .Text
        }
        
        func isPhoto() -> Bool {
            return self == .Photo
        }
        
        func isVideo() -> Bool {
            return self == .Video
        }
    }
    
    var senderId:String!
    var senderDisplayName:String!
    var date:NSDate?
    var type:MessageType!
    var data:JSQMessage?
    var fileURL:String?
    
    func initMessage(senderId: String!, senderDisplayName: String!, date: NSDate!, type: MessageType!, data: AnyObject!) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.date = date
        self.type = type
        
        if type.isText() {
            self.data = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: self.date, text: data as! String)
        } else if type.isPhoto() || type.isVideo() {
            let photoItem = JSQPhotoMediaItem(image: data as! UIImage)
            self.data = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: self.date, media: photoItem)
        } else {
            self.data = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: self.date, media: data as! JSQMessageMediaData)
        }
    }
    
    init(senderId: String!, senderDisplayName: String!, date: NSDate!, type: MessageType!, data: AnyObject!) {
        
        super.init()
        self.initMessage(senderId, senderDisplayName: senderDisplayName, date: date, type: type, data: data)
    }
    
    init(senderId: String!, senderDisplayName: String!, type: MessageType!, data: AnyObject!) {
        
        super.init()
        self.initMessage(senderId, senderDisplayName: senderDisplayName, date: NSDate(), type: type, data: data)
    }
}
