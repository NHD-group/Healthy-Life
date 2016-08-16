//
//  chatterModel.swift
//  HealthyLife
//
//  Created by admin on 8/8/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import Foundation

class Chatter: NSObject {
    
    var chatterName: NSString?
   
    
    var chatRoomKey: NSString?
    
    var id: NSString?
    
    init(key: String , dictionary: NSDictionary) {
        
      chatterName = key
        
      chatRoomKey = dictionary["chatRoomKey"] as? String

    id = dictionary["id"] as? String
    }
    
}
