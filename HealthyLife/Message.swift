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
    }
    
    var senderId:String!
    var senderDisplayName:String!
    var date:NSDate?
    var type:MessageType!
    var data:JSQMessage?
    
    init(senderId: String!, senderDisplayName: String!, date: NSDate!, type: MessageType!, data: AnyObject!) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.date = date
        self.type = type
        if type == .Text {
            self.data = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: self.date, text: data as! String)
        } else if type == .Photo {
            let photoItem = JSQPhotoMediaItem(image: data as! UIImage)
            self.data = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: self.date, media: photoItem)
        } else if type == .Video {
            let url = NSURL(string: data as! String)
            let videoItem = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true)
            self.data = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: self.date, media: videoItem)
        } else {
            self.data = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: self.date, media: data as! JSQMessageMediaData)
        }
    }
    
    init(senderId: String!, senderDisplayName: String!, type: MessageType!, data: AnyObject!) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.type = type
        if type == .Text {
            self.data = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: data as! String)
        }
        else if type == .Photo {
            let photoItem = JSQPhotoMediaItem(image: data as! UIImage)
            self.data = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: photoItem)
        } else if type == .Video {
            let url = NSURL(string: data as! String)
            let videoItem = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true)
            self.data = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: videoItem)
        }
            
        else {
            self.data = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: data as! JSQMessageMediaData)
        }
    }
}
