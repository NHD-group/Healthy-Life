//
//  followerModel.swift
//  HealthyLife
//
//  Created by admin on 8/5/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation

class Follower: NSObject {
    
    var Key: NSString?
    var Name: NSString?
   
    
    init(key: String, dictionary: NSDictionary) {
        Key = key
        Name = dictionary["name"] as? String
    }
    
}
