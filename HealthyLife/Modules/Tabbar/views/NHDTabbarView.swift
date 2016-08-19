//
//  NHDTabbarView.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 5/8/16.
//  Copyright © 2016 NHD group. All rights reserved.
//

import UIKit

protocol NHDTabbarViewDelegate: class {
 
    func tabWasSelected(index: Int)
}

class NHDTabbarView: UIView {
    
    weak var delegate: NHDTabbarViewDelegate?
    var selectedIndex = 0

    @IBOutlet var containerView: UIView!

    
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
        let nib = UINib(nibName: String(NHDTabbarView), bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        
        containerView.frame = bounds
        addSubview(containerView)
    }

    @IBAction func onButtonTapped(button: UIButton) {
        
        if selectedIndex != button.tag {
            button.selected = !button.selected
            
            button.transform = CGAffineTransformMakeScale(0.1, 0.1)
            UIView.animateWithDuration(2.0,
                                       delay: 0,
                                       usingSpringWithDamping: 0.2,
                                       initialSpringVelocity: 6.0,
                                       options: UIViewAnimationOptions.AllowUserInteraction,
                                       animations: {
                                        button.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
        
        selectedIndex = button.tag
        for subview in containerView.subviews {
            
            if subview.isKindOfClass(UIButton) && subview.tag != selectedIndex {
                (subview as! UIButton).selected = false
            }
        }
        
        delegate?.tabWasSelected(selectedIndex)
    }

}
