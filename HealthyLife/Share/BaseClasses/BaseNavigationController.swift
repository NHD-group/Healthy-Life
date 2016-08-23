//
//  BaseNavigationController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 4/8/16.
//  Copyright © 2016 NHD group. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    var topView: UIView!
    
    override func viewDidLoad() {
        
        navigationBar.barTintColor = Configuration.Colors.primary
        navigationBar.barStyle = .Black
        navigationBar.tintColor = UIColor.whiteColor()
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        topView = UIView(frame:
            CGRect(
                x: 0,
                y: -statusBarHeight,
                width: navigationBar.frame.width,
                height: statusBarHeight
            )
        )
        
        topView.backgroundColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.1)
        navigationBar.addSubview(topView)
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: NHDFontBucket.boldItalicFontWithSize(20)
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: NHDFontBucket.blackFontWithSize(12)], forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        topView.transform = CGAffineTransformMakeScale(0.1, 0.2)
//        UIView.animateWithDuration(3.0,
//                                   delay: 0,
//                                   usingSpringWithDamping: 0.3,
//                                   initialSpringVelocity: 5.0,
//                                   options: UIViewAnimationOptions.CurveLinear,
//                                   animations: {
//                                    self.topView.transform = CGAffineTransformIdentity
//            }, completion: nil)
    }
}
