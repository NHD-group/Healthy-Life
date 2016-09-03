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
    
    func uploadImageWithKey(key: String, complete: (() -> ())?, fail: ((error:NSError?) -> ())?) {
        
        let imageRef = FIRStorage.storage().reference().child("images/\(key)")

        if var avatarImage = self.image {
            
            avatarImage = avatarImage.resizeImage(CGSize(width: 100.0, height: 100.0))
            let imageData: NSData = UIImagePNGRepresentation(avatarImage)!
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if (error != nil) {
                    fail?(error: error)
                } else {
                    complete?()
                }
            }
        } else {
            complete?()
        }
    }
    

    func downloadImageWithKey(key: String) {
        let imageRef = FIRStorage.storage().reference().child("images/\(key)")
        downloadImageWithImageReference(imageRef, complete: nil)
    }
    
    func downloadImageWithImageReference(imageRef : FIRStorageReference) {
        downloadImageWithImageReference(imageRef, complete: nil)
    }
    
    func downloadImageWithImageReference(imageRef : FIRStorageReference, complete: ((image: UIImage) -> ())?) {
        
        let imageCache = ImageCache(name: "ImageCacheFolder")
        let key = imageRef.fullPath
        
        imageCache.retrieveImageForKey(key, options: []) { (cachedImage, type) in
            if cachedImage != nil {
                self.image = cachedImage
                if complete != nil {
                    complete!(image: cachedImage!)
                }
            } else {
                imageRef.dataWithMaxSize(Configuration.kMaxSize) { (data, error) -> Void in
                    
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                        NSLog((error?.description)!)
                    } else {
                        // Data for "images/island.jpg" is returned
                        let responseImage: UIImage! = UIImage(data: data!)
                        imageCache.storeImage(responseImage, originalData: data, forKey: key, toDisk: true, completionHandler: nil)
                        
                        self.image = responseImage
                        if complete != nil {
                            complete!(image: responseImage)
                        }
                    }
                }

            }
        }
        
    }
    
    func thumbnailForVideoAtURL(url: NSURL) {
        
        if let image = Helper.thumbnailForVideoAtURL(url) {
            self.image = image
        }
    }

}
