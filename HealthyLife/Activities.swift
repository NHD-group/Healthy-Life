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
    private var Des: String!
    private var VideoUrl: String!
    private var Rep : String!
    private var Set : String!
    private var CreatorID: String!
    private var FinishCount: Int!
    
    
    
    var keyDaily: String {
        return KeyActivities
    }
    
    var name: String {
        return Name
    }
    
    var des: String {
        return Des
    }
    
    var videoUrl: String {
        return VideoUrl
    }
    
    var rep: String {
        return Rep
    }
    
    var set: String {
        return Set
    }
    
    var creatorID: String {
        return CreatorID
    }
    
    var finsihCount: Int {
        return FinishCount
    }
    
    
    
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.KeyActivities = key
        
        // Within the Joke, or Key, the following properties are children
        
        if let name = dictionary["name"] as? String {
            self.Name = name
        }
        
        if let de = dictionary["description"] as? String {
            self.Des = de
        }
        
        if let Url = dictionary["videoUrl"] as? String {
            self.VideoUrl = Url
        }
        
        if let rep = dictionary["rep"] as? String {
            self.Rep = rep
        }
        
        if let set = dictionary["set"] as? String {
            self.Set = set
        }
        
        if let fcount = dictionary["finishCount"] as? Int {
            self.FinishCount = fcount
        }
        
        
        if let createrID = dictionary["creatorID"] as? String {
            self.CreatorID = createrID
        }
        
    }
    
    
    
    
}
