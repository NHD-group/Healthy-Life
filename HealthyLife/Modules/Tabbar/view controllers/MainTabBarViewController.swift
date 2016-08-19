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
        
        let tabbarView = NHDTabbarView(frame: self.tabBar.frame)
        view.addSubview(tabbarView)
        tabbarView.snp_makeConstraints { (make) in
            make.edges.equalTo(tabBar.snp_edges)
        }
        tabbarView.delegate = self
        
        
        NSNotificationCenter.defaultCenter().addObserverForName("kUploadVideoNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notif) in
            
            if let path = notif.object as? String {
                
                let vc = uploadVideoViewController(nibName: String(uploadVideoViewController), bundle: nil)
                
                let navVC = BaseNavigationController(rootViewController: vc)
                
                self.presentViewController(navVC, animated: true, completion: nil)
                
                vc.videoUrl = NSURL(fileURLWithPath: path)
                NSLog("videpath = %@", path)

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

}

extension MainTabBarViewController: NHDTabbarViewDelegate {
    
    func tabWasSelected(index: Int) {
        
        if index == 2 {
            
            if let navVC = selectedViewController as? UINavigationController {
                navVC.popViewControllerAnimated(true)
            }
        } else if index == 4 {
            
//            NSNotificationCenter.defaultCenter().postNotificationName("kUploadVideoNotification", object: "/Users/duynguyen/Library/Developer/CoreSimulator/Devices/CA6453B4-D011-4A6F-A7CA-BACB13902A7D/data/Containers/Data/Application/7AFEDBD6-DE2B-4F8B-9FBC-E115C43C8982/tmp/trim.435D9255-39BE-450C-9A8D-48431CF51209.MOV")
            let storyboard = UIStoryboard(name: "Recorder", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                presentViewController(vc, animated: true, completion: nil)
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

