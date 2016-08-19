//
//  Helper.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 19/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class Helper: NSObject {
    
    static func showAlert(title: String, message: String?, inViewController nav: UIViewController) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
            
        }
        
        alertVC.addAction(OKAction)
        nav.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    
    static func getPresentationDateString(sinceDate: NSDate) -> String {
        let DateFormatter = NSDateFormatter()
        DateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        DateFormatter.timeStyle = .ShortStyle
        return DateFormatter.stringFromDate(sinceDate)
    }
    
    static func getDecimalFormattedNumberString(number: NSNumber) -> String {
        let NumberFormatter = NSNumberFormatter()
        NumberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        return NumberFormatter.stringFromNumber(number)!
    }
}
