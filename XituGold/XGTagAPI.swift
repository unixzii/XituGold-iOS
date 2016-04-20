//
//  XGTagAPI.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/20.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import Foundation
import RxSwift
import AVOSCloud

class XGTagAPI: NSObject {

    class func fetchTags() -> Observable<[XGTag]> {
        return Observable<[AnyObject]>.create { observer in
            let query = AVQuery(className: "Tag")
            query.addDescendingOrder("subscribersCount")
            
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
        .map { (objects) -> [XGTag] in
            objects.map {
                let avo = $0 as! AVObject
                let transformed = XGTag()
                transformed.title = avo.objectForKey("title") as? String
                transformed.color = avo.objectForKey("color") as? String
                transformed.entriesCount = avo.objectForKey("entriesCount") as? Int ?? 0
                transformed.subscribersCount = avo.objectForKey("subscribersCount") as? Int ?? 0
                transformed.objectRef = avo
                
                if let icon = avo.objectForKey("icon") as? AVFile {
                    transformed.icon = NSURL(string: icon.url)
                }
                
                return transformed
            }
        }
        .retry(3)
    }
    
}
