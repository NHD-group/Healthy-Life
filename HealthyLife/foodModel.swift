
//  foodModel.swift
//  HealthyLife
//
//  Created by admin on 7/27/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation
import Firebase

class Food {
    private var FoodRef: FIRDatabaseReference!
    
    private var FoodKey: String!
    private var FoodDes: String!
    private var Love: Int!
    private var Time: NSDate!
    var currentID = (FIRAuth.auth()?.currentUser?.uid)!
    
    var foodKey: String {
        return FoodKey
    }
    
    var foodDes: String {
        return FoodDes
    }
    
    var love: Int {
        return Love
    }
    
    var time: NSDate {
        return Time
    }
    
    
    
    
    // Initialize the new Joke
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.FoodKey = key
        
        // Within the Joke, or Key, the following properties are children
        
        if let des = dictionary["Description"] as? String {
            self.FoodDes = des
        }
        
        if let lo = dictionary["Love"] as? Int {
            self.Love = lo
        }
        
        if let T = dictionary["time"] as? Double {
            self.Time = NSDate(timeIntervalSince1970: T/1000)
        }
        
        
        // The above properties are assigned to their key.
        
        self.FoodRef = FIRDatabase.database().reference().child("users").child(currentID).child("food_journal").child(self.FoodKey)
    }
    
    func addSubtractLove(addVote: Bool) {
        
        if addVote {
            Love = Love + 1
        } else {
            Love = Love - 1
        }
        
        // Save the new vote total.
        
        FoodRef.child("Love").setValue(Love)
        
    }
    
    
    
}