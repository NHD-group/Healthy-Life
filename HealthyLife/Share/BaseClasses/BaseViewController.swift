//
//  BaseViewController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 19/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase

class BaseViewController: UIViewController {

    var tapOnKeyboard: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.presentingViewController != nil {
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setBackgroundImage(UIImage(named: "close-icon"), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(self.onBack), forControlEvents: UIControlEvents.TouchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        } else if navigationItem.leftBarButtonItem == nil && navigationController?.viewControllers.count == 1 {
            
            displayLogoutButton()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(BaseViewController.keyboardWillAppear), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(BaseViewController.keyboardWillDisappear), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func displayLogoutButton() {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setBackgroundImage(UIImage(named: "log_off"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.logOutAction), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func keyboardWillAppear() {
        
        if tapOnKeyboard == nil {
            tapOnKeyboard = UITapGestureRecognizer(target: self, action: #selector(BaseViewController.dismissKeyboard))
        }
        view.addGestureRecognizer(tapOnKeyboard!)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardWillDisappear() {
        if tapOnKeyboard != nil {
            view.removeGestureRecognizer(tapOnKeyboard!)
        }
    }
    
    func onBack() {
        
        if self.presentingViewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func logOutAction() {
        
        Helper.showAlert("Warning", message: "Are you sure you want to log out?", okActionBlock: {
            try! FIRAuth.auth()!.signOut()
            
            NSNotificationCenter.defaultCenter().postNotificationName(Configuration.NotificationKey.userDidLogout, object: nil)
            }, cancelActionBlock: {}, inViewController: self)
        
    }
    func showLoading() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    func hideLoading() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
}
