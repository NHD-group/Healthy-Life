//
//  ResultModel.swift
//  HealthyLife
//
//  Created by admin on 8/19/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import Foundation

import Firebase


class Result {
    private var ResultRef: FIRDatabaseReference!
    
    private var ResultKey: String!
    private var CurrentWeight: String!
    private var Love: Int!
    private var Time: NSDate!
    
    
    var resultKey: String {
        return ResultKey
    }
    
    var currentWeight: String {
        return CurrentWeight
    }
    
    var love: Int {
        return Love
    }
    
    var time: NSDate {
        return Time
    }
    
    
    
    
    // Initialize the new Joke
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.ResultKey = key
        
        // Within the Joke, or Key, the following properties are children
        
        if let weight = dictionary["CurrentWeight"] as? String {
            self.CurrentWeight = weight
        }
        
        if let lo = dictionary["Love"] as? Int {
            self.Love = lo
        }
        
        if let T = dictionary["time"] as? Double {
            self.Time = NSDate(timeIntervalSince1970: T/1000)
        }
        
        
        // The above properties are assigned to their key.
        
        self.ResultRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("results_journal").child(self.ResultKey)
    }
    
    func addSubtractLove(addVote: Bool) {
        
        if addVote {
            Love = Love + 1
        } else {
            Love = Love - 1
        }
        
        // Save the new vote total.
        
        ResultRef.child("Love").setValue(Love)
        
    }
    
    
    
}