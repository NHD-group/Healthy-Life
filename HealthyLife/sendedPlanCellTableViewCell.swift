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
            
             DataService.dataService.activitiesPlannedRef.child("sendedPlan").child(plan).child("senderID").observeEventType(.Value, withBlock: { snapshot in
                self.keyUID = snapshot.value as? String ?? ""
                print(snapshot.value)
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
