//
//  userSettingModel.swift
//  HealthyLife
//
//  Created by admin on 8/4/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation

class UserSetting: NSObject {

    var DOB: String?
    var weightChanged: String?
    var height: String?
    
    init(dictionary: NSDictionary) {
      
        DOB = (dictionary["DOB"] as? String) ?? ""
        weightChanged = (dictionary["weight changed"] as? String) ?? "0"
        height = (dictionary["height"] as? String) ?? "0"
    }
    
}
