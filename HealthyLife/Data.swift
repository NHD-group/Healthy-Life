//
//  Data.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class DataService {
    
    static var dataService = DataService()
    
    static var BaseRef = FIRDatabase.database().reference()
    static let storageRef = FIRStorage.storage().reference()
    static let currentUser = FIRAuth.auth()?.currentUser
    static var currentUserID : String! {
        get {
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                return uid
            }
            return ""
        }
    }
    static var currentUserName : String! {

        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let userName = defaults.valueForKey("currentUserName") {
                return userName as! String
            }
            return currentUser?.displayName
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(newValue, forKey: "currentUserName")
        }
    }
    
    private var UserRef = DataService.BaseRef.child("users").child(currentUserID)
    
    
    private var FoodJournalRef = DataService.BaseRef.child("users").child(currentUserID).child("food_journal")
    
    private var ActivitiesJournalRef = DataService.BaseRef.child("users").child(currentUserID).child("activities_journal")
    
    private var ActivitiesPlannedRed = DataService.BaseRef.child("users").child(currentUserID).child("activities_planned")
    
    private var ChatRoom = DataService.BaseRef.child("users").child(currentUserID).child("chatRoom")
    private var Chats = DataService.BaseRef.child("chats")
    
    var baseRef: FIRDatabaseReference {
        DataService.BaseRef.keepSynced(true)
        return DataService.BaseRef
    }
    
    var userRef: FIRDatabaseReference{
        UserRef.keepSynced(true)
        return UserRef
    }
    
    var foodJournalRef: FIRDatabaseReference{
        FoodJournalRef.keepSynced(true)
        return FoodJournalRef
    }
    
    var activitiesJournalRef: FIRDatabaseReference {
        ActivitiesJournalRef.keepSynced(true)
        return ActivitiesJournalRef
    }
    
    var activitiesPlannedRef: FIRDatabaseReference {
        ActivitiesPlannedRed.keepSynced(true)
        return ActivitiesPlannedRed
    }
    
    var chatRoom: FIRDatabaseReference {
        ChatRoom.keepSynced(true)
        return ChatRoom
    }
    
    var chats: FIRDatabaseReference {
        Chats.keepSynced(true)
        return Chats
    }
    
    
    static func setup() {
        
        FIRApp.configure()
        FIRAnalyticsConfiguration.sharedInstance().setAnalyticsCollectionEnabled(false)
        FIRDatabase.database().persistenceEnabled = false
        FIRConfiguration.sharedInstance().logLevel = .Error

        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if user != nil {
                dataService = DataService()
            }
        })
    }
    
    static func isLoggedIn() -> Bool {
        
        return (currentUser != nil)
    }
    
    class func isSimulator() -> Bool {
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            return true
        #endif
        return false
    }
    
    static func updateToken() {
        if !isLoggedIn() {
            return
        }
        
//        FIRMessaging.messaging().subscribeToTopic("/topics/user_" + currentUserID);

        if isSimulator() {
            return
        }

        if let refreshedToken = FIRInstanceID.instanceID().token() {
            DataService.dataService.userRef.child("token").setValue(refreshedToken)
        }
    }

    static func sendPushNotification(message: String, from senderid: String, to userid: String, badge: Int, type: String) {
        
        if userid.characters.count == 0 {
            return
        }
        
        
        DataService.BaseRef.child("users").child(userid).child("token").observeEventType(.Value, withBlock: { snapshot in
            
            var list = [String]()

            if let token = snapshot.value as? String {
                list.append(token)
            }
//            list.append("/topics/user_" + senderid)
//            list.append("/topics/user_" + userid)
            
            for address in list {
                let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")
                let body = ["to" : address,
                    "notification" : [
                        "body"  : message,
                        "title" : "Healthy Life",
                        "badge" : badge,
                        "type"  : type,
                        "senderid" : senderid ?? ""
                    ]]
                let jsonData = try! NSJSONSerialization.dataWithJSONObject(body, options: [])
                
                let request = NSMutableURLRequest(URL: url!)
                request.HTTPMethod = "POST"
                request.HTTPBody = jsonData
                
                let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                // get key at https://console.firebase.google.com/project/healthylife-d0cfe/settings/cloudmessaging
                configuration.HTTPAdditionalHeaders = [
                    "Authorization": "key=AIzaSyCMD1sIRWpSnoZz-PdH6MErqJmuJyiTHUs",
                    "Content-Type": "application/json"]
                let session = NSURLSession(
                    configuration: configuration,
                    delegate:nil,
                    delegateQueue:NSOperationQueue.mainQueue()
                )
                
                let task : NSURLSessionDataTask = session.dataTaskWithRequest(
                    request,
                    completionHandler: { (dataOrNil, response, error) in
                        if error != nil {
                            print(error.debugDescription)
                        } else {
                            
                        }
                });
                task.resume()
                
            }
           
        })
        
    }
    
    
    class func uploadImage(image: UIImage, key: String, complete: (downloadURL: NSURL?) -> (), errorBlock: (error: NSError) -> ()) {
        
        let resizedImage = image.resizeImage(CGSize(width: 500.0, height: 500.0))
        let imageData: NSData = UIImagePNGRepresentation(resizedImage)!
        let riversRef = FIRStorage.storage().reference().child("images/\(key)")
        
        // Upload the file to the path ""images/\(key)"
        riversRef.putData(imageData, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
                errorBlock(error: error!)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let url = metadata!.downloadURL
                complete(downloadURL: url())
            }
        }
    }
}

