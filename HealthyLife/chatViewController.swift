//
//  chatViewController.swift
//  HealthyLife
//
//  Created by admin on 8/8/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import Kingfisher
import MobileCoreServices
import MBProgressHUD
import AVKit

class chatViewController: JSQMessagesViewController {
    
    var chatRoomTittle: String?
    
    let storageRef = FIRStorage.storage().reference()
    
    var messageRef: FIRDatabaseReference!
    
    var messages = [Message]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var chatKey = String()
    //MARK: Check when user typing
    
    var userIsTypingRef: FIRDatabaseReference! // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    var receiverid : String {
        get {
            return chatKey.stringByReplacingOccurrencesOfString(senderId, withString: "")
        }
    }
    
    var usersTypingQuery: FIRDatabaseQuery!
    
    let imagePicker = UIImagePickerController()
    
    
    //*******
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageRef = DataService.dataService.chats.child(chatKey)
        
        title = chatRoomTittle
        setupBubbles()
        
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.messageBubbleFont = NHDFontBucket.blackFontWithSize(15)
        
        observeMessages()
        observeTyping()
        
        // Do any additional setup after loading the view.
        setupBackButton()
        
        resetUnreadMessage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Configuration.selectedRoomKey = receiverid
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Configuration.selectedRoomKey = ""
    }
    
    func setupBackButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setBackgroundImage(UIImage(named: "close-icon"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.onBack), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func onBack() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backAction(sender: AnyObject) {
        onBack()
        
    }
    //MARK: add message to firebase
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageRef.childByAutoId() // 1
        
        let messageItem = [ // 2
            "type": Message.MessageType.Text.rawValue,
            "text": text,
            "senderId": senderId
        ]
        
        itemRef.setValue(messageItem) // 3
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
        
        isTyping = false
        
        DataService.sendPushNotification(senderDisplayName + ": " + text, from: senderId, to: receiverid, badge: 1, type: "chat")
        updateUnreadMessage()
    }
    
    func addTextMessage(key: String!, id: String, text: String) {
        let message = Message(key: key, senderId: id, senderDisplayName: "", type: .Text, data: text)
        messages.append(message)
    }
    
    func addPhotoMessage(key: String!, id: String, photo: UIImage, type: Message.MessageType?, fileURL: String?) {
        let message = Message(key: key, senderId: id, senderDisplayName: "", type: type, data: photo)
        message.fileURL = fileURL
        messages.append(message)
    }
    
    //************
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            Configuration.Colors.veryYellow)
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            Configuration.Colors.paleLimeGreen)
    }
    
    //MARK: checkMessage
    
    private func observeMessages() {
        // 1
        let messagesQuery = messageRef.queryLimitedToLast(25)
        
        // 2
        messageRef.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in

            guard let value = snapshot.value else {
                return
            }
            // 3
            let key = snapshot.key
            let id = value["senderId"] as! String
            let text = value["text"] as! String
            
            var type = Message.MessageType.Text.rawValue
            if let Type = value["type"] as? String {
                type = Type
            }
            
            if type == Message.MessageType.Photo.rawValue {
               
                    if let image = UIImage.getImageFromText(text) {
                        self.addPhotoMessage(key, id: id, photo: image, type: Message.MessageType.Photo, fileURL: nil)
                    }
                
            } else if type == Message.MessageType.Video.rawValue {
                
                if let image = UIImage.getImageFromText(text) {
                    self.addPhotoMessage(key, id: id, photo: image, type: Message.MessageType.Video, fileURL: value["fileURL"] as? String)
                }
                
            } else {
                self.addTextMessage(key, id: id, text: text)
            }
            self.finishReceivingMessage()

        }
    }
    
    //********
    
    //MARK: detect when user typing
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    private func observeTyping() {
        let typingIndicatorRef = DataService.dataService.baseRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        // 1
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        // 2
        usersTypingQuery.observeEventType(.Value) { (data: FIRDataSnapshot!) in
            
            // 3 You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 4 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
        
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].data
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.type.isText() {
            if message.senderId == senderId {
                cell.textView!.textColor = Configuration.Colors.primary
            } else {
                cell.textView!.textColor = UIColor.darkGrayColor()
            }
        } else if message.type.isVideo() {
            let frame = cell.frame
            let width = frame.size.width / 1.7
            let imageView = UIImageView(frame: CGRectMake(message.senderId == senderId ? frame.size.width - width : 0, 0, width, frame.size.height))
            imageView.image = UIImage(named: "lightboxPlayIconW")
            imageView.contentMode = .ScaleAspectFit
            imageView.alpha = 0.7
            cell.addSubview(imageView)

        }
        return cell
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
   
        let message = messages[indexPath.item]
        if message.type.isVideo() {
            
            NHDVideoPlayerViewController.showPlayer(nil, orLink: message.fileURL, title: senderDisplayName, inViewController: self)
        }
    }
    
    
    func updateUnreadMessage() {
        
        let ref = DataService.dataService.baseRef.child("users").child(receiverid).child("chatRoom").child(DataService.currentUserName).child("unreadMessage")
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            var count = 1
            if let value = snapshot.value as? Int {
                count += value
            }
            
            ref.setValue(count)

            DataService.dataService.baseRef.child("users").child(self.receiverid).child("totalUnread").observeSingleEventOfType(.Value, withBlock: { (snap) in
                
                var total = 1
                if let val = snap.value as? Int {
                    total += val
                }
                
                snap.ref.setValue(total)
            })
        })
        
    }
    
    func resetUnreadMessage() {
        
        let ref = DataService.dataService.chatRoom.child(chatRoomTittle!).child("unreadMessage")
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            var count = 0
            if let value = snapshot.value as? Int {
                count += value
            }
            
            ref.setValue(0)
            
            DataService.dataService.userRef.child("totalUnread").observeSingleEventOfType(.Value, withBlock: { (snap) in
                
                var total = 0
                if let val = snap.value as? Int {
                    total = val - count
                }
                
                snap.ref.setValue(total)
            })
        })
        
    }

}

extension chatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var image: UIImage?
        var videoURL: NSURL?
        
        if let url = info[UIImagePickerControllerMediaURL] as? NSURL {
            videoURL = url
        }
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = pickedImage
        }
        
        if let videoURL = videoURL {
            
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)

            let itemRef = self.messageRef.childByAutoId()
            
            FIRStorage.storage().reference().child("videosChat").child(itemRef.key).putFile(videoURL, metadata: nil, completion: { (metadata, error) in
                if error  != nil {
                    
                    Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                } else {
                    if let videoUrl = metadata?.downloadURL()?.absoluteString {

                        let type = Message.MessageType.Video.rawValue
                        let thumbnail = Helper.thumbnailForVideoAtURL(videoURL)
//                        let watermark = UIImage(named: "lightboxPlayIconW")!
//                        watermark.resizeImage(thumbnail!.size)
//                        thumbnail = thumbnail?.addWaterMark(UIImage(named: "lightboxPlayIconW")!)

                        let messageItem = [ // 2
                            "type": type,
                            "text": thumbnail?.convertImageToString(CGSize(width: 500, height: 500)) ?? "",
                            "fileURL": videoUrl,
                            "senderId": self.senderId
                        ]
                        itemRef.setValue(messageItem)
                        
                        self.finishSendingMessage()
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        
                        DataService.sendPushNotification(self.senderDisplayName + " sent a video to you", from: self.senderId, to: self.receiverid, badge: 1, type: "chat")
                        self.updateUnreadMessage()
                    }
                    
                }
            })
            
        }
        
        if let image = image {
            let itemRef = self.messageRef.childByAutoId() //
            
            var type = Message.MessageType.Photo.rawValue
            let fileURL = videoURL?.absoluteString ?? ""
            if videoURL != nil {
                type = Message.MessageType.Video.rawValue
            }
            let messageItem = [ // 2
                "type": type,
                "text": image.convertImageToString(CGSize(width: 500, height: 500)),
                "fileURL": fileURL,
                "senderId": self.senderId
            ]
            
            itemRef.setValue(messageItem)
            
            self.finishSendingMessage()
            
            DataService.sendPushNotification(senderDisplayName + " sent a photo to you", from: senderId, to: receiverid, badge: 1, type: "chat")
            updateUnreadMessage()
        }
        
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
