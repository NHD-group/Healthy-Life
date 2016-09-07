//
//  UIImageExtension.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 1/8/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func convertImageToString(targetSize: CGSize) -> String {
        
        let image = self.resizeImage(targetSize)
        let imageData: NSData = UIImageJPEGRepresentation(image, Configuration.compressionQuality)!
        let dataStr = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return dataStr
    }
    
    static func getImageFromText(text: String!) -> UIImage? {
        if let imageData = NSData(base64EncodedString: text, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) {
            
            if let image = UIImage(data: imageData) {
                return image
            }
        }
        return nil
    }
    
    func addWaterMark(watermarkImage: UIImage) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        drawInRect(CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        watermarkImage.drawInRect(CGRect(x: (size.width - watermarkImage.size.width) / 2, y: (size.height - watermarkImage.size.height) / 2, width: watermarkImage.size.width, height: watermarkImage.size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}
