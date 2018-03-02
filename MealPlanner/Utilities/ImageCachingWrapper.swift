//
//  ImageCachingWrapper.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 27/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import Foundation
import AlamofireImage

class ImageCachingWrapper {
    
    // Set maximum cache size and preferrred size to cut down to when max is reached
    let imageCache = AutoPurgingImageCache(memoryCapacity: UInt64(100).megabytes(), preferredMemoryUsageAfterPurge: UInt64(60).megabytes())
    
    /**
        A function that uses AlamofireImage to add an image to the imageCache using a specified identifier, here we use the url of the image as it is likely unique.
     
        - Parameters:
            - image: The image to cache
            - url: The url of the image provided, to be used as an identifier for storing in cache
     */
    func cache(_ image: Image, for url: String) {
        imageCache.add(image, withIdentifier: url)
    }
    
    /**
        A function to return a cached image if it is found.
     
        - Parameters:
            - url: The url that identifies the image to be returned.
     */
    func cachedImage(for url: String) -> Image? {
        return imageCache.image(withIdentifier: url)
    }
    
}

extension UInt64 {
    func megabytes() -> UInt64 {
        return self * 1024 * 1024
    }
}
