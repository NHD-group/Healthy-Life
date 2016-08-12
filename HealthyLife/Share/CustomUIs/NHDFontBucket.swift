//
//  NHDFontBucket.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 6/8/16.
//  Copyright © 2016 NHD group. All rights reserved.
//

import UIKit

class NHDFontBucket {
    
    static func fontWithSize(size: CGFloat) -> UIFont {
        
        return UIFont(name: "Chams", size: size) ?? UIFont.systemFontOfSize(size)
    }
    
    static func boldFontWithSize(size: CGFloat) -> UIFont {
        
        return UIFont(name: "Chams-Bold", size: size) ?? UIFont.boldSystemFontOfSize(size)
    }
    
    static func italicFontWithSize(size: CGFloat) -> UIFont {
        
        return UIFont(name: "Chams-Italic", size: size) ?? UIFont.italicSystemFontOfSize(size)
    }
    
    static func boldItalicFontWithSize(size: CGFloat) -> UIFont {
        
        return UIFont(name: "Chams-BoldItalic", size: size) ?? UIFont.italicSystemFontOfSize(size)
    }
    
    static func blackFontWithSize(size: CGFloat) -> UIFont {
        
        return UIFont(name: "Chams-Black", size: size) ?? UIFont.boldSystemFontOfSize(size)
    }
}

class NHDCustomFontLabel: UILabel {
    
    override func awakeFromNib() {
        
        font = NHDFontBucket.fontWithSize(font.pointSize - 1)
    }
}

class NHDCustomItalicFontLabel: UILabel {
    
    override func awakeFromNib() {
        
        font = NHDFontBucket.italicFontWithSize(font.pointSize - 1)
    }
}

class NHDCustomFontButton: UIButton {
    
    override func awakeFromNib() {
        
        if let titleLabel = titleLabel {
            titleLabel.font = NHDFontBucket.blackFontWithSize(titleLabel.font.pointSize)
            titleLabel.adjustsFontSizeToFitWidth = true
        }
    }
}