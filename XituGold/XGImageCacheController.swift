//
//  XGImageCacheController.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/20.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class XGImageCacheController: NSObject {

    static let sharedController = XGImageCacheController()
    
    private var cachedImages = [NSURL:UIImage]()
    private let lock = NSLock()
    
    func putImage(image: UIImage, forKey key: NSURL) {
        performInCriticalZone {
            self.cachedImages[key] = image
            return nil
        }
    }
    
    func imageForKey(key: NSURL) -> UIImage? {
        return performInCriticalZone {
            return self.cachedImages[key]
        } as? UIImage
    }
    
    func clearCache() {
        self.cachedImages.removeAll()
    }

    func performInCriticalZone(action: () -> AnyObject?) -> AnyObject? {
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        
        return action()
    }
    
}
