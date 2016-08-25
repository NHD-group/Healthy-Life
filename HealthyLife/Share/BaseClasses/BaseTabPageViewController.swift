//
//  BaseTabPageViewController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 25/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import TabPageViewController

protocol BaseTabPageViewControllerDelegate: class {
    
    func pageViewControllerWasSelected(index: Int)
}


protocol BaseScroolViewDelegate: class {
    
    func pageViewControllerIsMoving(isUp: Bool)
}


class BaseTabPageViewController: TabPageViewController {

    weak var actionDelegate: BaseTabPageViewControllerDelegate?

    var currentIndex: Int? {
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return tabItems.map{ $0.viewController }.indexOf(viewController)
    }

    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: options)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var option = TabPageOption()
        option.currentColor = Configuration.Colors.primary
        option.tabWidth = view.frame.width / CGFloat(self.tabItems.count)
        self.option = option
        delegate = self
    }
}


extension BaseTabPageViewController {
    
    override func displayControllerWithIndex(index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool) {

        super.displayControllerWithIndex(index, direction: direction, animated: animated)
        
        actionDelegate?.pageViewControllerWasSelected(index)
    }
    
}