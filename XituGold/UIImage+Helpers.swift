//
//  UIImage+Helpers.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func imageFilledWithColor(color: UIColor) -> UIImage {
        let size = CGSize(width: 1, height: 1)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        color.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(origin: CGPointZero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}