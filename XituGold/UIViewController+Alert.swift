//
//  UIViewController+Alert.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/20.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlertWithTitle(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "好的", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}