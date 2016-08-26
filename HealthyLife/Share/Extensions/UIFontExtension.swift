//
//  UIFontExtension.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 26/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

extension UIFont {
    
    func heightOfString (string: NSString, constrainedToWidth width: Double) -> CGFloat {
        return string.boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
                                           options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                           attributes: [NSFontAttributeName: self],
                                           context: nil).size.height
    }
}
