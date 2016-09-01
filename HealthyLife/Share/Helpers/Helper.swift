//
//  Helper.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 19/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import MBProgressHUD
import AVFoundation

class Helper: NSObject {
    
    static func showAlert(title: String, message: String?, okActionBlock: (()->())?, cancelActionBlock: (()->())?, inViewController nav: UIViewController) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelActionBlock != nil {
            let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                cancelActionBlock!()
            }
            alertVC.addAction(CancelAction)
        }
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            if okActionBlock != nil {
                okActionBlock!()
            }
        }
        
        alertVC.addAction(OKAction)
        nav.presentViewController(alertVC, animated: true, completion: nil)
        MBProgressHUD.hideHUDForView(nav.view, animated: true)
    }
    
    static func showAlert(title: String, message: String?, inViewController nav: UIViewController) {
        var viewController = nav
        if let vc = viewController.presentedViewController {
            viewController = vc
        }
        showAlert(title, message: message, okActionBlock: nil, cancelActionBlock: nil, inViewController: viewController)
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
    
    static func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
        let asset = AVAsset(URL: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        var time = asset.duration
        time.value = min(time.value, 1)
        do {
            let imageRef = try assetImageGenerator.copyCGImageAtTime(time, actualTime: nil)
            return UIImage(CGImage: imageRef)
        } catch {
            
        }
        return nil
    }
    
    class func getRootViewController() -> UIViewController? {
        return UIApplication.sharedApplication().keyWindow?.rootViewController
    }
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
