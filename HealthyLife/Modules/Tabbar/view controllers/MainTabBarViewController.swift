//
//  MainTabBarViewController.swift
//  HealthyLife
//
//  Created by admin on 8/3/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import SnapKit

class MainTabBarViewController: UITabBarController  {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tabbarView = NHDTabbarView(frame: tabBar.frame)
        view.addSubview(tabbarView)
        tabbarView.snp_makeConstraints { (make) in
            make.edges.equalTo(tabBar.snp_edges)
        }
        tabbarView.delegate = self
        
        
        let splashView = NHDSplash(frame: view.frame)
        view.addSubview(splashView)
        splashView.snp_makeConstraints { (make) in
            make.edges.equalTo(view.snp_edges)
        }
        splashView.delegate = self
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.getNotificationUploadVideo), name: Configuration.NotificationKey.uploadVideo, object: nil)
    }
    
    func getNotificationUploadVideo(notif: NSNotification) {
        if Configuration.selectedViewControllerName == String(self) {
            
            if let path = notif.object as? String {
                
                let vc = uploadVideoViewController(nibName: String(uploadVideoViewController), bundle: nil)
                let navVC = BaseNavigationController(rootViewController: vc)
                self.presentViewController(navVC, animated: true, completion: {
                    vc.videoUrl = NSURL(fileURLWithPath: path)
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "uploadVideoSegue" {
            let vc = segue.destinationViewController as! uploadVideoViewController
            if let url = sender as? NSURL {
                vc.videoUrl = url
            }
        }
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
  
        return .Portrait
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
}

extension MainTabBarViewController: NHDTabbarViewDelegate {
    
    func tabWasSelected(index: Int) {
        
        if index < 4 {
            
            if let navVC = selectedViewController as? UINavigationController {
                navVC.popViewControllerAnimated(true)
            }
        } else if index == 4 {
            
            let storyboard = UIStoryboard(name: "Recorder", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                presentViewController(vc, animated: true, completion: nil)
                Configuration.selectedViewControllerName = String(self)
            }
        }
        
        guard let items = tabBar.items else {
            return
        }
        
        if index < items.count {
            
            selectedIndex = index
        }
    }
}


extension MainTabBarViewController: NHDSplashDelegate {
    
    func onStop() {

    }
}
