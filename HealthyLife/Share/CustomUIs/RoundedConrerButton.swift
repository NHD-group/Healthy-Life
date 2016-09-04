//
//  RoundedConrerButton.swift
//  FoxPlay2-iOS
//
//  Created by Duy Nguyen on 31/8/16.
//  Copyright © 2016 2359 Media. All rights reserved.
//

import UIKit

class NHDRoundedConrerButton: NHDCustomSubmitButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = CGRectGetHeight(bounds)/2.0
        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.borderWidth = 1.0
        
        contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20)
    }
}
