//
//  SignInViewController.swift
//  HealthyLife
//
//  Created by admin on 7/26/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import LocalAuthentication
import FBSDKLoginKit

class SignInViewController: BaseViewController {
    
    
    let animationDuration: CFTimeInterval = 0.5
    
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var createEmail: UITextField!
    
    @IBOutlet weak var createUsername: UITextField!
    
    @IBOutlet weak var touchIDButton: UIButton!
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
    
    
    @IBOutlet weak var backGroundImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startingDisplay()
        
        let email = defaults.valueForKey("email")
        let password = defaults.valueForKey("password")
        
        if email == nil && password == nil {
            touchIDButton.hidden = true
        } else {
            touchIDButton.hidden = false
        }
        
        self.emailTextField.returnKeyType = .Next
        self.createEmail.returnKeyType = .Next
        self.createUsername.returnKeyType = .Next
        self.passwordTextField.returnKeyType = .Done
        self.createPassword.returnKeyType = .Done
        
        self.emailTextField.delegate = self
        self.createEmail.delegate = self
        self.createUsername.delegate = self
        self.passwordTextField.delegate = self
        self.createPassword.delegate = self
        
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self
        facebookView.addSubview(fbLoginButton)
        fbLoginButton.snp_makeConstraints { (make) in
            make.edges.equalTo(facebookView)
        }
    }

    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func LoginButton(sender: UIButton) {
        
        login()
    }
    
    @IBAction func createAccountAction(sender: AnyObject) {
        createAccount()
    }
    
    
    @IBAction func displaySignInViewAction(sender: AnyObject) {
        UIView.animateWithDuration(animationDuration) {
            self.displaySignIn()
        }
    }
    
    
    @IBAction func displayCreateAccountViewAction(sender: AnyObject) {
        UIView.animateWithDuration(animationDuration) {
            self.displayCreateAccount()
        }
        
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        UIView.animateWithDuration(animationDuration) {
            self.startingDisplay()
        }
        
    }
    
    @IBAction func touchIDLoginAction(sender: AnyObject) {
        let email = defaults.valueForKey("email") as? String
        let password = defaults.valueForKey("password") as? String
        if email != "" && password != "" {
            
            
            TouchIDCall(email!, password: password!)
            showLoading()
            
        }
        print(email)
        print(password)
        
    }
    
    func TouchIDCall(email: String, password: String) {
        let authContext: LAContext = LAContext()
        var error: NSError?
        if authContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            authContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "LogIn With TouchID", reply: { (sucessed, error) in
                if sucessed {
                        print("works")
                    
                //handle Sucess
                
                        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                                
                            } else {
                                self.getDetailsOfUser()
                              print("work work work")
                            }
                        })

                    
                } else {
                    
                }
            })
        } else {
            
        }
    }
    
    
    func startingDisplay() {
        viewEffect.alpha = 0
        logInView.alpha = 0
        displayCButton.alpha = 1
        displaySButton.alpha = 1
        facebookView.alpha = 1
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
        facebookView.alpha = 0
        createAccountView.alpha = 0
        
        logInView.layer.cornerRadius = 10
        logInView.clipsToBounds = true
        
        
    }
    
    func displayCreateAccount() {
        viewEffect.alpha = 1
        createAccountView.alpha = 1
        displayCButton.alpha = 0
        displaySButton.alpha = 0
        facebookView.alpha = 0
        logInView.alpha = 0
        
        createAccountView.layer.cornerRadius = 10
        createAccountView.clipsToBounds = true
        
    }
    
    
    func login() {
        dismissKeyboard()
        showLoading()
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                if error != nil {
                    Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                    self.hideLoading()
                } else {
                    self.getDetailsOfUser()
                    self.saveDataUser(email, password: password)
                }
            })
        } else {
            Helper.showAlert("Oops", message: "Please fill in all the fields", inViewController: self)
            self.hideLoading()
        }
        
    }
    
    func saveDataUser(email: String, password: String) {
        defaults.setValue(email, forKey: "email")
        defaults.setValue(password, forKey: "password")
    }
    
    func createAccount() {
        dismissKeyboard()
        showLoading()
        if let email = createEmail.text, let password = createPassword.text, let username = createUsername.text {
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                if error != nil {
                    Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                    self.hideLoading()
                } else {
                    FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                        if error != nil {
                            
                        } else {
                            DataService.dataService.userRef.setValue(["username" : username ,  "followerCount" : 0, "totalRate": 0, "totalPeoleVoted": 0, "userCommentsCount": 0  ])
                            
                            self.getDetailsOfUser()
                            self.saveDataUser(email, password: password)
                        }
                    })
                }
                
            })
        } else {
            Helper.showAlert("Oops", message: "Please fill in all the fields", inViewController: self)
            self.hideLoading()
        }
        
    }
    
    func getDetailsOfUser() {
        
        DataService.dataService.userRef.child("username").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let userName = snapshot.value as? String {
                DataService.currentUserName = userName
            }
            self.hideLoading()
            DataService.updateToken()

            NSNotificationCenter.defaultCenter().postNotificationName(Configuration.NotificationKey.userDidLogin, object: nil)
        })
    }
    
    
    
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
            break
        case passwordTextField:
            login()
            break
        case createEmail:
            createUsername.becomeFirstResponder()
            break
        case createUsername:
            createPassword.becomeFirstResponder()
            break
        case createPassword:
            createAccount()
            break
        default:
            break
        }
        return true
    }
}

extension SignInViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        showLoading()
        if let error = error {
            
            Helper.showAlert("Error", message: error.localizedDescription, inViewController: self)
            self.hideLoading()
        } else if result.isCancelled == false {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                if let user = user {
                    let ref =  FIRDatabase.database().reference()
                    
                    ref.child("users").child(user.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        if snapshot.value is NSNull {
                            snapshot.ref.setValue(["username" : user.displayName ?? "Facebook user", "followerCount" : 0, "totalRate": 0, "totalPeoleVoted": 0, "userCommentsCount": 0, "photoURL" : user.photoURL?.absoluteString ?? ""  ])
                        }
                    })
                    
                    self.getDetailsOfUser()
                } else {
                    Helper.showAlert("Error", message: "Can not login with Facebook", inViewController: self)
                    self.hideLoading()
                }
            }
        } else {
            self.hideLoading()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
}

