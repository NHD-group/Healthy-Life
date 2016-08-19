//
//  Configuration.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 4/8/16.
//  Copyright © 2016 NHD group. All rights reserved.
//

import UIKit

class Configuration: NSObject {
    
    struct Colors {
        static let primary = UIColor(red:0.82, green:0.27, blue:0.25, alpha:1.0)        // #cf473f
        static let brightRed = UIColor(red:0.875, green:0.235, blue:0.176, alpha:1.0)   // #df3c2d
        static let softCyan = UIColor(red:0.694, green:0.933, blue:0.953, alpha:1.0)  // #b1eef3
        static let veryYellow = UIColor(hex: 0xFCFF91)
        static let paleLimeGreen = UIColor(hex: 0xBBFFBF)
        
    }
    
    struct NotificationKey {
        static let userDidLogout = "userDidLogoutNotificationKey"
        static let userDidLogin = "userDidLoginNotificationKey"
        static let uploadVideo = "kUploadVideoNotification"
    }

    static let animationDuration: CFTimeInterval = 0.3
    static var selectedViewControllerName: NSString?

}
