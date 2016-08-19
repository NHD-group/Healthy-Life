//
//  BaseViewController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 19/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.presentingViewController != nil {
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            button.setBackgroundImage(UIImage(named: "close-icon"), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(self.onBack), forControlEvents: UIControlEvents.TouchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
    
    func onBack() {
        
        if self.presentingViewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
}
