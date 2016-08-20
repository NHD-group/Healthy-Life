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
import Kingfisher

class chatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    }
    
    func addTextMessage(id: String, text: String) {
        //let message = JSQMessage(senderId: id, displayName: "", text: text)
        let message = Message(senderId: id, senderDisplayName: "", type: .Text, data: text)
        messages.append(message)
    }
    
    func addPhotoMessage(id: String, photo: UIImage) {
        let message = Message(senderId: id, senderDisplayName: "", type: .Photo, data: photo)
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
            // 3
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String

            var type = Message.MessageType.Text.rawValue
            if let Type = snapshot.value!["type"] as? String {
                type = Type
            }
            
            if type == Message.MessageType.Photo.rawValue {
                let imageData = NSData(base64EncodedString: text, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                let image = UIImage(data: imageData!)
                self.addPhotoMessage(id, photo: image!)
            } else {
                self.addTextMessage(id, text: text)
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
        }
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let image = pickedImage.resizeImage(CGSize(width: 500, height: 500))
            
            let imageData:NSData = UIImagePNGRepresentation(image)!
            
            let dataStr = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
            let itemRef = self.messageRef.childByAutoId() //
            
            let messageItem = [ // 2
                "type": Message.MessageType.Photo.rawValue,
                "text": dataStr ,
                "senderId": self.senderId
            ]
            
            itemRef.setValue(messageItem)
            
            self.finishSendingMessage()
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
