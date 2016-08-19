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
import AVFoundation

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
    
    func thumbnailForVideoAtURL(url: NSURL) {
        let asset = AVAsset(URL: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        var time = asset.duration
        time.value = min(time.value, 1)
        do {
            let imageRef = try assetImageGenerator.copyCGImageAtTime(time, actualTime: nil)
            image = UIImage(CGImage: imageRef)
        } catch {
            
        }
    }

}
