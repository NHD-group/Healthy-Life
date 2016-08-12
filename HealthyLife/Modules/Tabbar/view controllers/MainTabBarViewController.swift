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
    }

}

extension MainTabBarViewController: NHDTabbarViewDelegate {
    
    func tabWasSelected(index: Int) {
        
        if index == 2 {
            
            if let navVC = selectedViewController as? UINavigationController {
                navVC.popViewControllerAnimated(true)
            }
        } else if index == 4 {
            
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

