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

class DataService {
    
    static let dataService = DataService()
    
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
    
    private var UserRef = DataService.BaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    
    
    private var FoodJournalRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("food_journal")
    
    private var ActivitiesJournalRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("activities_journal")
    
    private var ActivitiesPlannedRed = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("activities_planned")
    
    private var ChatRoom = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("chatRoom")
    private var Chats = FIRDatabase.database().reference().child("chats")
    
    var baseRef: FIRDatabaseReference {
        return DataService.BaseRef
    }
    
    var userRef: FIRDatabaseReference{
        return UserRef
    }
    
    var foodJournalRef: FIRDatabaseReference{
        return FoodJournalRef
    }
    
    var activitiesJournalRef: FIRDatabaseReference {
        return ActivitiesJournalRef
    }
    
    var activitiesPlannedRef: FIRDatabaseReference {
        return ActivitiesPlannedRed
    }
    
    var chatRoom: FIRDatabaseReference {
        return ChatRoom
    }
    
    var chats: FIRDatabaseReference {
        return Chats
    }
    
    
    static func setup() {
        
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        FIRDatabase.database().persistenceEnabled = false
        FIRConfiguration.sharedInstance().logLevel = .Error
    }
    
    static func isLoggedIn() -> Bool {
        
        return (currentUser != nil)
    }
    
    static func updateToken() {
        
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            // don't save token in simulator
            return
        #endif
        
        if !isLoggedIn() {
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
            
            guard let token = snapshot.value as? String else {
                return
            }
            
            let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")
            let body = ["to" : token,
                "notification" : [
                    "body"  : message,
                    "title" : "Healthy Life",
                    "badge" : badge,
                    "type"  : type,
                    "senderid" : senderid
                ]]
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(body, options: [])
            
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.HTTPBody = jsonData
            
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = ["Authorization": "key=AIzaSyCMD1sIRWpSnoZz-PdH6MErqJmuJyiTHUs", "Content-Type": "application/json"]
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
        })
        
    }
}

