//
//  Configuration.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 4/8/16.
//  Copyright © 2016 NHD group. All rights reserved.
//

import UIKit

class Configuration: NSObject {
    
    static let userDidLogoutNotificationKey = "userDidLogoutNotificationKey"
    static let userDidLoginNotificationKey = "userDidLoginNotificationKey"
    
    static let animationDuration: CFTimeInterval = 0.3

    struct Colors {
        static let primary = UIColor(red:0.82, green:0.27, blue:0.25, alpha:1.0)
    }
}
