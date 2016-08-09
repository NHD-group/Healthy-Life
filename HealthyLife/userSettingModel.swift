//
//  userSettingModel.swift
//  HealthyLife
//
//  Created by admin on 8/4/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation

class UserSetting: NSObject {

    var DOB: NSString?
    var weightChanged: NSString?
    var height: NSString?
    
    init(dictionary: NSDictionary) {
      
        DOB = (dictionary["DOB"] as? String) ?? "non"
        weightChanged = (dictionary["weight changed"] as? String) ?? "non"
        height = (dictionary["height"] as? String) ?? "non"
    }
    
}
