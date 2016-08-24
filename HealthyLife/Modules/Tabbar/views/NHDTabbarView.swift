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
    @IBOutlet var badgeLabel: UILabel!

    
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
        
        badgeLabel.hidden = true
        badgeLabel.text = "0"
        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.width / 2
        badgeLabel.layer.masksToBounds = true
        
        DataService.dataService.baseRef.child("users").child(DataService.currentUserID).child("totalUnread").observeEventType(.Value, withBlock: { snapshot in
            
            var count = 0
            if let value = snapshot.value as? Int {
                count = value
            }
            
            if count > 0 {
                self.badgeLabel.hidden = false
                self.badgeLabel.text = String(count)
            } else {
                self.badgeLabel.hidden = true
            }
            UIApplication.sharedApplication().applicationIconBadgeNumber = count
        })
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
