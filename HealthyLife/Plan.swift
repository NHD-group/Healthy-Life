//
//  Plan.swift
//  HealthyLife
//
//  Created by admin on 8/6/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation

class Plan: NSObject {
    
    var activities: NSDictionary?
    var note: NSString?
    var plan_CreatorID: NSString?
    var plan_CreatorName: NSString?
    
    init(dictionary: NSDictionary) {
        
        activities = dictionary["activities"] as? NSDictionary
        
        note = dictionary["note"] as? String
        plan_CreatorID = dictionary["plan_creatorID"] as? String
        plan_CreatorName = dictionary["plan_creatorName"] as? String
        
        
       
    }
    
}

