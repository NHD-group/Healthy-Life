//
//  newFeed.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation
import Firebase



class UserProfile: NSObject {
    private var FollowerCountRef: FIRDatabaseReference!
    var UserKey: String?
    var username: String?
    var followerCount: Int?
    var userSetting: UserSetting?
    var totalStar: Int?
    var totalPeopleVoted: Int?
    var userCommentCount: Int?
    
    init(key: String, dictionary: NSDictionary) {
        UserKey = key
        username = dictionary["username"] as? String
        followerCount = dictionary["followerCount"] as? Int
        
        if let setting = dictionary["user_setting"] as? NSDictionary {
            userSetting = UserSetting(dictionary: setting)
        }
        
        totalStar = dictionary["totalRate"] as? Int
        totalPeopleVoted = dictionary["totalPeoleVoted"] as? Int
        userCommentCount = dictionary["userCommentsCount"] as? Int
        FollowerCountRef =  DataService.dataService.baseRef.child("users").child(UserKey!)
        
        
    }
    
    
    
    
    
    func addSubTractFollower(addFollower: Bool) {
        if addFollower {
            followerCount = followerCount! + 1
        } else {
            followerCount = followerCount! - 1
        }
        FollowerCountRef.child("followerCount").setValue(followerCount)
    }
    
    
}