//
//  BaseTabPageViewController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 25/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import TabPageViewController

class BaseTabPageViewController: TabPageViewController {

    var currentIndex: Int? {
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return tabItems.map{ $0.viewController }.indexOf(viewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var option = TabPageOption()
        option.currentColor = Configuration.Colors.primary
        option.tabWidth = view.frame.width / CGFloat(self.tabItems.count)
        self.option = option
    }
}


extension BaseTabPageViewController {
    
    internal override func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        super.pageViewController(pageViewController, didFinishAnimating: finished, previousViewControllers: previousViewControllers, transitionCompleted: completed)
        
        
    }
}