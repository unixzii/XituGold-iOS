//
//  XGNavigationController.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class XGNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle() ?? super.preferredStatusBarStyle()
    }

}


extension XGNavigationController: UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
}