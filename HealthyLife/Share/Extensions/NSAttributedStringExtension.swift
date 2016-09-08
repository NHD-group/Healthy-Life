//
//  NSAttributedStringExtension.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 8/9/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//


extension NSMutableAttributedString {
    
    func bold(text:String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : NHDFontBucket.boldFontWithSize(fontSize)]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.appendAttributedString(boldString)
        return self
    }
    
    func italic(text:String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : NHDFontBucket.italicFontWithSize(fontSize)]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.appendAttributedString(boldString)
        return self
    }
    
    func normal(text:String) -> NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.appendAttributedString(normal)
        return self
    }
}