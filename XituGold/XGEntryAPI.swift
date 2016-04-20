//
//  XGEntryAPI.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import Foundation
import RxSwift
import AVOSCloud

let XGOrderTypeOptionName = "XGOrderTypeOptionName"
let XGTagOptionName = "XGTagOptionName"
let XGDTagOptionName = "XGDTagOptionName"
let XGObjectsOptionName = "XGObjectIdsOptionName"


class XGEntryAPI: NSObject {

    class func searchWithKeyword(keyword: String) -> Observable<[XGEntry]> {
        return Observable<[AnyObject]>.create { observer in
            let query = AVSearchQuery.searchWithQueryString(keyword)
            query.className = "Entry"
            query.cachePolicy = .CacheElseNetwork
            query.maxCacheAge = 60
            
            SMNetworkActivityController.sharedController.endActivity()
            
            query.findInBackground { (objects, error) in
                SMNetworkActivityController.sharedController.endActivity()
                
                if error != nil {
                    observer.onError(error)
                    return
                }
                
                observer.onNext(objects)
                observer.onCompleted()
            }
            
            return NopDisposable.instance
        }.flatMap { objects -> Observable<[XGEntry]> in
            return XGEntryAPI.fetchEntries(withOptions: [XGObjectsOptionName: objects])
        }
    }
    
    class func fetchEntries(skipCount: Int = 0, withOptions options: [String:AnyObject?]) -> Observable<[XGEntry]> {
        return Observable<[AnyObject]>.create { observer -> Disposable in
            let query = AVQuery(className: "Entry")
            query.limit = 10
            query.skip = skipCount
            
            if options[XGOrderTypeOptionName] as? Int == 1 {
                query.orderByDescending("createdAt")
            } else {
                query.orderByDescending("rankIndex")
            }
            
            if let tag = options[XGTagOptionName] as? String where !tag.isEmpty {
                query.whereKey("category", equalTo: tag)
            }
            
            if let dtag = options[XGDTagOptionName] {
                query.whereKey("tags", equalTo: dtag)
            }
            
            if let objects = options[XGObjectsOptionName] as? [AVObject] {
                query.whereKey("objectId", containedIn: objects.map { $0.objectId })
            }
            
            SMNetworkActivityController.sharedController.startActivity()
            
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                SMNetworkActivityController.sharedController.endActivity()
                
                if (error != nil) {
                    observer.onError(error)
                    return
                }
                
                observer.onNext(objects)
                observer.onCompleted()
            }
            
            return NopDisposable.instance
        }
        .map { (objects) -> [XGEntry] in
            objects.map {
                let avo = $0 as! AVObject
                let transformed = XGEntry()
                transformed.title = avo.objectForKey("title") as? String
                transformed.category = avo.objectForKey("category") as? String
                transformed.content = avo.objectForKey("content") as? String
                transformed.createdAt = avo.createdAt
                transformed.hotIndex = avo.objectForKey("hotIndex") as? Int ?? -1
                transformed.URL = NSURL(string: avo.objectForKey("url") as? String ?? "")
                transformed.tags.appendContentsOf(avo.objectForKey("tagsTitleArray") as? [String] ?? [])
                transformed.commentsCount = avo.objectForKey("commentsCount") as? Int ?? 0
                transformed.collectionCount = avo.objectForKey("collectionCount") as? Int ?? 0
                transformed.viewsCount = avo.objectForKey("viewsCount") as? Int ?? 0
                
                // Check out whether there is a screenshot
                if let screenshot = avo.objectForKey("screenshot") as? AVFile {
                    transformed.screenshot = NSURL(string: screenshot.url)
                }
                
                return transformed
            }
        }
        .retry(3)
    }
    
}
