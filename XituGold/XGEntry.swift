//
//  XGEntry.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import Foundation

class XGEntry: NSObject {

    var title: String?
    var category: String?
    var content: String?
    var createdAt: NSDate?
    var hotIndex = -1
    var URL: NSURL?
    var screenshot: NSURL?
    var tags = [String]()
    var commentsCount = 0
    var collectionCount = 0
    var viewsCount = 0
    
}
