//
//  SMNetworkActivityController.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class SMNetworkActivityController {
    
    static let sharedController = SMNetworkActivityController()
    
    private enum SMState {
        case Invisible
        case WillShow
        case Visible
        case WillHide
    }
    
    private let lock = NSLock()
    
    private var activityCount = 0
    
    private var state: SMState = .Invisible {
        didSet {
            currentCancelable?()
            
            switch state {
            case .Invisible:
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                break
            case .WillShow:
                currentCancelable = delay(forMilliseconds: 100) {
                    if self.state == .WillShow {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                        self.state = .Visible
                    }
                }
                break
            case .Visible:
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                break
            case .WillHide:
                currentCancelable = delay(forMilliseconds: 300) {
                    if self.state == .WillHide {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.state = .Invisible
                    }
                }
                break
            }
        }
    }
    
    private var currentCancelable: (Void -> Void)?
    
    func startActivity() {
        performInCriticalZone {
            self.activityCount += 1
            
            return nil
        }
        
        switch state {
        case .Invisible:
            state = .WillShow
            break
        case .WillHide:
            state = .Visible
            break
        default:
            break
        }
    }
    
    func endActivity() {
        let count = performInCriticalZone {
            self.activityCount -= 1
            
            if self.activityCount < 0 {
                self.activityCount = 0
            }
            
            return self.activityCount
        }! as! Int
        
        if count > 0 {
            return
        }
        
        switch state {
        case .Visible:
            state = .WillHide
            break
        case .WillShow:
            state = .Invisible
            break
        default:
            break
        }
        
    }
    
    private func delay(forMilliseconds ms: UInt64, action: Void -> Void) -> (Void -> Void) {
        var cancelled = false
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * ms))
        dispatch_after(time, dispatch_get_main_queue()) {
            if !cancelled {
                action()
            }
        }
        
        return {
            cancelled = true
        }
    }
    
    private func performInCriticalZone(action: Void -> AnyObject?) -> AnyObject? {
        lock.lock()
        
        defer {
            lock.unlock()
        }
        
        return action()
    }
    
}
