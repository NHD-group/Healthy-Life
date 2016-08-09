//
//  DailyPlan.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation
import Firebase

class Activities {
    
       
    private var KeyActivities: String!
    
    private var Name: String!
    private var IDvideo: String!
    private var Rep : String!
    private var Set : String!
    
    
    
    var keyDaily: String {
        return KeyActivities
    }
    
    var name: String {
        return Name
    }
    
    var idVideo: String {
        return IDvideo
    }
    
    var rep: String {
        return Rep
    }
    
    var set: String {
        return Set
    }
    
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.KeyActivities = key
        
        // Within the Joke, or Key, the following properties are children
        
        if let name = dictionary["name"] as? String {
            self.Name = name
        }
        
        if let id = dictionary["videoId"] as? String {
            self.IDvideo = id
        }
        
        if let rep = dictionary["rep"] as? String {
            self.Rep = rep
        }
        
        if let set = dictionary["set"] as? String {
            self.Set = set
        }
        
        
//        FIRDatabase.database().reference().child("demo_lib").child(self.KeyDemo)
    }
    
    
    
    
}
