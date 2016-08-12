//
//  UIImageViewExtension.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 2/8/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

extension UIImageView {
    

    func downloadImageWithImageReference(imageRef : FIRStorageReference) {
        
        let imageCache = ImageCache(name: "ImageCacheFolder")
        let key = imageRef.fullPath
        
        imageCache.retrieveImageForKey(key, options: []) { (cachedImage, type) in
            if cachedImage != nil {
                self.image = cachedImage
            } else {
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                imageRef.dataWithMaxSize((1 * 1024 * 1024)/2) { (data, error) -> Void in
                    
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let responseImage: UIImage! = UIImage(data: data!)
                        imageCache.storeImage(responseImage, originalData: data, forKey: key, toDisk: true, completionHandler: nil)
                        
                        self.image = responseImage
                    }
                }

            }
        }
        
    }
}
