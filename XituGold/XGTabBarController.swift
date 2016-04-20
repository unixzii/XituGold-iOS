//
//  XGTabBarController.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class XGTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        let explorerVC = XGExplorerViewController()
        explorerVC.tabBarItem.image = UIImage(named: "icon_explore")
        explorerVC.tabBarItem.selectedImage = UIImage(named: "icon_explore_active")
        explorerVC.tabBarItem.title = "发现"
        
        let tagVC = XGTagViewController()
        tagVC.tabBarItem.image = UIImage(named: "icon_tags")
        tagVC.tabBarItem.selectedImage = UIImage(named: "icon_tags_active")
        tagVC.tabBarItem.title = "标签"
        
        self.viewControllers = [explorerVC, tagVC]
        self.tabBarController(self, didSelectViewController: explorerVC)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle() ?? .LightContent
    }

}


extension XGTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationItem.title = viewController.navigationItem.title
        self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems
        self.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
}
