//
//  AppDelegate.swift
//  HealthyLife
//
//  Created by admin on 7/26/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let notificationSetting = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSetting)

        
        DataService.setup()

        changeRootView(DataService.isLoggedIn(), animated: false)
        window?.makeKeyAndVisible()
        
        NSNotificationCenter.defaultCenter().addObserverForName(Configuration.NotificationKey.userDidLogout, object: nil, queue: NSOperationQueue.mainQueue()) { (notif) in
            
            self.changeRootView(false, animated: true)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Configuration.NotificationKey.userDidLogin, object: nil, queue: NSOperationQueue.mainQueue()) { (notif) in
            
            self.changeRootView(true, animated: false)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.tokenRefreshNotificaiton),
                                                         name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        return true
    }

    func changeRootView(isLoggedIn: Bool, animated: Bool) {
        let storyboardName = isLoggedIn ? "Main" : "SignIn"
        let storyBoard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyBoard.instantiateInitialViewController()
        if animated == false {
            self.window?.rootViewController = vc
            return
        }
        
        UIView.transitionWithView(self.window!, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
            self.window?.rootViewController = vc
            }, completion: nil)
    }

    
    func tokenRefreshNotificaiton(notification: NSNotification) {
        
        DataService.updateToken()
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
        DataService.updateToken()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
        FIRMessaging.messaging().disconnect()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        connectToFcm()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        var badge = 0
        var senderId = ""
        var shouldShowAlert = false
        if let type = userInfo["notification"]?["type"] as? String {
            switch type {
            case "chat":
                badge += Int(userInfo["notification"]?["badge"] as! String)!
                senderId = userInfo["notification"]?["senderid"] as! String
            default:
                badge += 1
                shouldShowAlert = true
                break
            }
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = badge

        print(userInfo)
        
        if !shouldShowAlert {
            return
        }
        
        if application.applicationState != .Inactive {
            var viewController = (window?.rootViewController)!
            if let vc = viewController.presentedViewController {
                viewController = vc
            }
            if Configuration.selectedRoomKey != senderId {
                Helper.showAlert("New Message", message: userInfo["notification"]?["body"] as? String, inViewController: viewController)
            }
        }
    }

}

