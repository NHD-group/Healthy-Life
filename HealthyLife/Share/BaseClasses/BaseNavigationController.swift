//
//  BaseNavigationController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 4/8/16.
//  Copyright © 2016 NHD group. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        
        navigationBar.barTintColor = Configuration.Colors.primary
        navigationBar.barStyle = .Black
        navigationBar.tintColor = UIColor.whiteColor()
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let topView = UIView(frame:
            CGRect(
                x: 0,
                y: -statusBarHeight,
                width: navigationBar.frame.width,
                height: statusBarHeight
            )
        )
        
        topView.backgroundColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.05)
        
        navigationBar.addSubview(topView)
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: NHDFontBucket.boldItalicFontWithSize(25)
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: NHDFontBucket.blackFontWithSize(12)], forState: .Normal)
    }
    
}
