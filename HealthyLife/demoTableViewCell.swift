//
//  demoTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 7/31/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit

class demoTableViewCell: UITableViewCell {

    @IBOutlet weak var videosLabel: UILabel!
    
    @IBAction func addAction(sender: AnyObject) {
    }
    var demo: Demo!
    
    
    func configureCell(demo : Demo) {
        
        self.demo = demo
        
        videosLabel.text = demo.nameDemo
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
