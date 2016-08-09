//
//  sendedPlanCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/7/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit

class sendedPlanCellTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var planName: UILabel!
    
    var plan: String! {
        didSet {
            planName.text = plan as? String
            
            
        }
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
