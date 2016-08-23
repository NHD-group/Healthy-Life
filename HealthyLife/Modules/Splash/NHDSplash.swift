//
//  NHDSplash.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 23/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

@objc protocol NHDSplashDelegate: class {
    
    optional func onStop()
}

class NHDSplash : UIView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var bottomView: UIImageView!
    @IBOutlet weak var topView: UIImageView!
    @IBOutlet weak var grayView: UIImageView!
    @IBOutlet weak var whiteView: UIImageView!
    @IBOutlet weak var redView: UIImageView!
    @IBOutlet weak var midView: UIImageView!
    @IBOutlet weak var textView: UIImageView!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var labelCopyright: NHDCustomBlackFontLabel!
    
    weak var delegate: NHDSplashDelegate?

    lazy var animator = UIDynamicAnimator()
    var gravity: UIGravityBehavior!
    var viewProperties: UIDynamicItemBehavior!
    var push: UIPushBehavior!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initSubviews()
    }
    
    
    func initSubviews() {
        // code to load subviews from nib here
        let nib = UINib(nibName: String(NHDSplash), bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        
        containerView.alpha = 0.9
        containerView.frame = bounds
        addSubview(containerView)
        
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(self.removeSplashScreen), userInfo: nil, repeats: true)
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
        containerView.addGestureRecognizer(tapGuesture)
        
        addAnimation()
        playAnimation()
    }
    
    func onTap(gesture: UIGestureRecognizer) {
        
        removeSplashScreen()
    }
    
    func removeSplashScreen() {
        // Add code to be run periodically
        
        UIView.animateWithDuration(0.1, animations: {
            self.containerView.alpha = 0
            }, completion: { (bool) -> Void in
                self.removeFromSuperview()
                self.delegate?.onStop?()
        })
    }
    
    func addAnimation() {
        
        viewProperties = UIDynamicItemBehavior(items: [bottomView])
        gravity = UIGravityBehavior(items: [bottomView])
        
    }
    
    func playAnimation() {
    
        let currentVelocity = viewProperties.linearVelocityForItem(bottomView)
        viewProperties.addLinearVelocity(CGPoint(x: currentVelocity.x, y: -currentVelocity.y), forItem: bottomView)
        
        push = UIPushBehavior(items: [bottomView], mode: UIPushBehaviorMode.Instantaneous)
        push.pushDirection = CGVectorMake(0, -0.5)
        push.active = true
        animator.addBehavior(push)
        animator.addBehavior(gravity)
        animator.addBehavior(viewProperties)
        
        let width = containerView.frame.size.width
        let height = containerView.frame.size.height
        
        UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
            
            self.midView.transform = CGAffineTransformMakeTranslation(-width, self.midView.frame.size.height)
            }, completion: { (bool) -> Void in
                
                UIView.animateWithDuration(0.5, delay: 0, options: [], animations: { () -> Void in
                    
                    self.redView.transform = CGAffineTransformMakeTranslation(-width, height - self.redView.frame.size.height)
                    self.redView.alpha = 0.5
                    
                    self.labelCopyright.transform = CGAffineTransformMakeTranslation(0, 100)
                    
                    }, completion: { (bool) -> Void in
                })
        })
        
        
        UIView.animateWithDuration(0.5, delay: 0, options: [], animations: { () -> Void in
            
            self.topView.transform = CGAffineTransformMakeTranslation(-self.topView.frame.size.width, -self.topView.frame.size.height)
            }, completion: { (bool) -> Void in
                
                UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
                    
                    self.grayView.transform = CGAffineTransformMakeTranslation(self.grayView.frame.size.width, self.grayView.frame.size.height)
                    }, completion: { (bool) -> Void in
                })
        })
        
        
        
        UIView.animateWithDuration(0.6, delay: 0, options: [], animations: { () -> Void in
            
            self.whiteView.transform = CGAffineTransformMakeTranslation(self.whiteView.frame.size.width, self.whiteView.frame.size.height)
            }, completion: { (bool) -> Void in
        })
        
        appIcon.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 6.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.appIcon.transform = CGAffineTransformIdentity
            }, completion: { (bool) -> Void in
                UIView.animateWithDuration(0.5, delay: 0, options: [], animations: { () -> Void in
                self.appIcon.transform = CGAffineTransformMakeTranslation(200, -300)
                    }, completion: { (bool) -> Void in

                })
        })
        
        textView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.3,
                                   initialSpringVelocity: 5.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.textView.transform = CGAffineTransformIdentity
            }, completion: { (bool) -> Void in
                UIView.animateWithDuration(0.5, delay: 0, options: [], animations: { () -> Void in
                    self.textView.transform = CGAffineTransformMakeTranslation(-300, 0)
                    self.textView.alpha = 0.5
                    }, completion: { (bool) -> Void in
                        self.removeSplashScreen()
                })
        })
    }
}
