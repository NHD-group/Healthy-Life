//
//  Data.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation
import Firebase

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
    
    private var UserRef = DataService.BaseRef.child("users").child(DataService.currentUserID)
    
    
    private var FoodJournalRef = FIRDatabase.database().reference().child("users").child(DataService.currentUserID).child("food_journal")
    
    private var ActivitiesJournalRef = FIRDatabase.database().reference().child("users").child(DataService.currentUserID).child("activities_journal")
    
    private var ActivitiesPlannedRed = FIRDatabase.database().reference().child("users").child(DataService.currentUserID).child("activities_planned")
    
    private var ChatRoom = FIRDatabase.database().reference().child("users").child(DataService.currentUserID).child("chatRoom")
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
        FIRConfiguration.sharedInstance().logLevel = .Error
    }
    
    static func isLoggedIn() -> Bool {
        
        return (currentUser != nil)
    }

}

