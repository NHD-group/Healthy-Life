//
//  SignInViewController.swift
//  HealthyLife
//
//  Created by admin on 7/26/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase


class SignInViewController: UIViewController {
    
    
    

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var createEmail: UITextField!
    
    @IBOutlet weak var createUsername: UITextField!
    
    @IBOutlet weak var createPassword: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var CreateAccountButton: UIButton!
    
    @IBOutlet weak var logInView: UIView!
    
    @IBOutlet weak var createAccountView: UIView!
    
    @IBOutlet weak var viewEffect: UIVisualEffectView!
    
    @IBOutlet weak var displaySButton: UIButton!
    
    @IBOutlet weak var displayCButton: UIButton!
     let defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
            self.startingDisplay()
      
        
    }

    
    @IBAction func LoginButton(sender: UIButton) {
        
        login()
    }
    
    @IBAction func createAccountAction(sender: AnyObject) {
        createAccount()
    }
    
    
    @IBAction func displaySignInViewAction(sender: AnyObject) {
         UIView.animateWithDuration(1) {
        self.displaySignIn()
        }
    }
    
    
    @IBAction func displayCreateAccountViewAction(sender: AnyObject) {
        UIView.animateWithDuration(1) { 
            self.displayCreateAccount()
        }
        
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        UIView.animateWithDuration(1) { 
            self.startingDisplay()
        }
        
    }
    

   
    
    func alertMessage (title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OK = UIAlertAction(title: "ok", style: .Default, handler: nil)
        alert.addAction(OK)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func startingDisplay() {
        viewEffect.alpha = 0
        logInView.alpha = 0
        displayCButton.alpha = 1
        displaySButton.alpha = 1
        createAccountView.alpha = 0
        
        displayCButton.layer.cornerRadius = 10
        displayCButton.clipsToBounds = true

        displaySButton.layer.cornerRadius = 10
        displaySButton.clipsToBounds = true
    }
    
    func displaySignIn() {
        
        viewEffect.alpha = 1
        logInView.alpha = 1
        displayCButton.alpha = 0
        displaySButton.alpha = 0
        createAccountView.alpha = 0
        
        logInView.layer.cornerRadius = 10
        logInView.clipsToBounds = true

        
    }
    
    func displayCreateAccount() {
        viewEffect.alpha = 1
        createAccountView.alpha = 1
        displayCButton.alpha = 0
        displaySButton.alpha = 0
        logInView.alpha = 0
        
        createAccountView.layer.cornerRadius = 10
        createAccountView.clipsToBounds = true

    }
    
    
    func login() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    
                    self.alertMessage("Error", message: "\(error?.localizedDescription)")
                    
                    
                    
                } else {
                    print(user)
                    print("User logged in")
                    self.performSegueWithIdentifier("1", sender: self)
                }
            })
        } else {
            alertMessage("Oops", message: "Please fill in all the fields")
        }

    }
    
    func createAccount() {
        if let email = createEmail.text, let password = createPassword.text, let username = createUsername.text {
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    self.alertMessage("Error", message: "\(error!.localizedDescription)")
                } else {
                    FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                        if error != nil {
                            
                        } else {
                        let ref =  FIRDatabase.database().reference()
                        ref.child("users").child(user!.uid).setValue(["username" : username ,  "followerCount" : 0 ])
                            
                            self.performSegueWithIdentifier("1", sender: self)
                        }
                    })
                }
                
            })
        } else {
            alertMessage("Oops", message: "Please fill in all the fields")
        }

    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}


