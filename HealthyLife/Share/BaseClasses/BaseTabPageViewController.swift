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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}


extension BaseTabPageViewController {
    
    override func displayControllerWithIndex(index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool) {

        view.userInteractionEnabled = false
        dispatch_async(dispatch_get_main_queue()) { 
            super.displayControllerWithIndex(index, direction: direction, animated: animated)
        }
        
        Helper.delay(Configuration.animationDuration) {
            self.view.userInteractionEnabled = true
            self.actionDelegate?.pageViewControllerWasSelected(index)
        }
        
    }
    
    
    class func scrollViewDidScroll(scrollView: UIScrollView, delegate: BaseScroolViewDelegate?) {
        
        if scrollView.decelerating {
        }
        
        let isUp = (scrollView.panGestureRecognizer.translationInView(scrollView.superview).y > 0) && scrollView.contentOffset.y <= 30
        
        delegate?.pageViewControllerIsMoving(isUp)
    }
    
}