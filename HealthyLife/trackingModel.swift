//
//  File.swift
//  HealthyLife
//
//  Created by admin on 8/6/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//


import Foundation

class Tracking: NSObject {
    
    var UserID: NSString?
    var name: NSString?
    var workingOn: NSDictionary?
    var nameOfPlan: NSString?
    var nameOfActivity: NSString?
   
    
    init(key: String, dictionary: NSDictionary) {
        UserID = key
        name = dictionary["name"] as? String
        
        
        if let workOn = dictionary["workingOn"] as? NSDictionary {
        workingOn = workOn
        nameOfPlan = workingOn!["nameOfPlan"] as? String
        nameOfActivity = workingOn!["activityName"] as? String
        }
        
    }
    
}


