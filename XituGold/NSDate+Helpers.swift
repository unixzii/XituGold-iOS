//
//  NSDate+Helpers.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import Foundation

extension NSDate {
    
    func formattedStringFromThenToNow() -> String {
        var timeInterval = NSDate(timeIntervalSinceNow: 0).timeIntervalSinceDate(self)
        
        if timeInterval < 60 {
            return "\(Int(timeInterval))秒"
        }
        
        timeInterval /= 60
        if timeInterval < 60 {
            return "\(Int(timeInterval))分钟"
        }
        
        timeInterval /= 60
        if timeInterval < 24 {
            return "\(Int(timeInterval))小时"
        }
        
        timeInterval /= 24
        if timeInterval < 30 {
            return "\(Int(timeInterval))天"
        }
        
        timeInterval /= 30
        if timeInterval < 12 {
            return "\(Int(timeInterval))月"
        }
        
        timeInterval /= 12
        return "\(Int(timeInterval))年"
    }
    
}