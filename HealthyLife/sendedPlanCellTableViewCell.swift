//
//  sendedPlanCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/7/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class sendedPlanCellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var planName: UILabel!
    
    var keyUID = String()
    
    
    
    var plan: String! {
        didSet {
            planName.text = plan
            let planRef =  DataService.dataService.activitiesPlannedRef.child("sendedPlan").child(plan)
            
            planRef.child("senderID").observeEventType(.Value, withBlock: { snapshot in
                self.keyUID = snapshot.value as? String ?? ""
            })
            
            planRef.child("checkVote").observeEventType(.Value, withBlock: { snapshot in
                if snapshot.value is NSNull {
                    self.rateButton.hidden = false
                } else {
                    
                    self.rateButton.hidden = true
                }
            })

            
            
        }
    }
    
    
    

    @IBAction func rateAction(sender: AnyObject) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    

}
