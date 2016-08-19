//
//  AppDelegate.swift
//  HealthyLife
//
//  Created by admin on 7/26/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        DataService.setup()

        changeRootView(DataService.isLoggedIn(), animated: false)
        window?.makeKeyAndVisible()
        
        NSNotificationCenter.defaultCenter().addObserverForName(Configuration.NotificationKey.userDidLogout, object: nil, queue: NSOperationQueue.mainQueue()) { (notif) in
            
            self.changeRootView(false, animated: true)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Configuration.NotificationKey.userDidLogin, object: nil, queue: NSOperationQueue.mainQueue()) { (notif) in
            
            self.changeRootView(true, animated: true)
        }
        
        return true
    }

    func changeRootView(isLoggedIn: Bool, animated: Bool) {
        let storyboardName = isLoggedIn ? "Main" : "SignIn"
        let storyBoard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyBoard.instantiateInitialViewController()

//        if isLoggedIn {
//            let journal = storyBoard.instantiateViewControllerWithIdentifier("personal") as! UINavigationController
//            let demoLib = storyBoard.instantiateViewControllerWithIdentifier("demoLib") as! UINavigationController
//            
//            let newFeed = storyBoard.instantiateViewControllerWithIdentifier("newFeed") as! UINavigationController
//            
//            let talks = storyBoard.instantiateViewControllerWithIdentifier("talks") as! UINavigationController
//            
//            let tabbarVC = MainTabBarViewController()
//            tabbarVC.viewControllers = [journal, demoLib, newFeed, talks]
//            vc = tabbarVC
//        }
//        
        if animated == false {
            self.window?.rootViewController = vc
            return
        }
        
        UIView.transitionWithView(self.window!, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
            self.window?.rootViewController = vc
            }, completion: nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

}

