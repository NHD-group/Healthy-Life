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
import SnapKit

class BaseViewController: UIViewController {

    var tapOnKeyboard: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.presentingViewController != nil && navigationItem.rightBarButtonItem == nil {
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setBackgroundImage(UIImage(named: "close-icon"), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(self.onBack), forControlEvents: UIControlEvents.TouchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        } else if navigationItem.leftBarButtonItem == nil && navigationController?.viewControllers.count == 1 {
            
            displayLogoutButton()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.keyboardWillAppear), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.keyboardWillDisappear), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func addSearchBarItem() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setBackgroundImage(UIImage(named: "icn-search"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.onSearch), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func onSearch() {
    }
    
    func addBackgroundImage() {
        
        let blurredBackground = UIImageView(frame: view.frame)
        blurredBackground.image = UIImage(named: "SignIn")
        blurredBackground.alpha = 0.3
        blurredBackground.blurImage()
        view.insertSubview(blurredBackground, atIndex: 0)
        blurredBackground.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let colorView = UIView(frame: view.frame)
        colorView.alpha = 0.3
        UIView.animateWithDuration(3, delay: 0.3, options:[UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: {
            colorView.backgroundColor = UIColor.blackColor()
            colorView.backgroundColor = UIColor.greenColor()
            colorView.backgroundColor = UIColor.grayColor()
            colorView.backgroundColor = Configuration.Colors.veryYellow
            }, completion: nil)
        view.insertSubview(colorView, atIndex: 0)
        colorView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func addGradientLayer() {
        let gl = CAGradientLayer()
        gl.colors = [ UIColor.whiteColor().CGColor, Configuration.Colors.lightGray.CGColor]
        gl.locations = [ 1.0, 0.0]
        gl.frame = view.frame
        view.layer.insertSublayer(gl, atIndex: 0)
    }
}
