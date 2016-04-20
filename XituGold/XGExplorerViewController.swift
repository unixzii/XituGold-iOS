//
//  XGExplorerViewController.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class XGExplorerViewController: UIViewController {

    var tableViewController: XGEntryTableViewController {
        return self._tableViewController
    }
    
    private var _tableViewController = XGEntryTableViewController()
        
    private var useDefaultStatusBarStyle = false
    private var needToReload = true
        
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let filterButtonItem = UIBarButtonItem(title: "筛选", style: .Plain, target: nil, action: nil)
        filterButtonItem.rx_tap
            .subscribeNext { [unowned self] in
                self.showFilterView()
            }.addDisposableTo(self.disposeBag)
        
        let actionButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: nil, action: nil)
        actionButtonItem.rx_tap
            .subscribeNext { [unowned self] in
                self.showActionSheet()
            }.addDisposableTo(self.disposeBag)
        
        self.navigationItem.title = "发现"
        self.navigationItem.leftBarButtonItems = [filterButtonItem]
        self.navigationItem.rightBarButtonItems = [actionButtonItem]
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableViewController.willMoveToParentViewController(self)
        self.addChildViewController(self.tableViewController)
        self.tableViewController.view.frame = self.view.bounds
        self.tableViewController.tableView.contentInset.bottom = 64
        self.view.addSubview(self.tableViewController.view)
        self.tableViewController.didMoveToParentViewController(self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.useDefaultStatusBarStyle ? .Default : .LightContent
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.needToReload {
            self.tableViewController.reload()
            self.needToReload = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: -
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "重新载入", style: .Default) { _ in
            self.tableViewController.reload()
        })
        actionSheet.addAction(UIAlertAction(title: "设置", style: .Default) { _ in
            let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shakeAnimation.values = [0, -20, 15, -10, 10, -9, 9, -6, 6, -1, 0]
            shakeAnimation.duration = 1.0
            
            UIApplication.sharedApplication().keyWindow?.layer.addAnimation(shakeAnimation, forKey: "")
        })
        actionSheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showFilterView() {
        let filterVC = XGFilterViewController()
        filterVC.selectedOrderType = self.tableViewController.selectedOrderType
        filterVC.selectedTag = self.tableViewController.selectedTag
        filterVC.delegate = self
        filterVC.rx_deallocated
            .subscribeNext {
                self.useDefaultStatusBarStyle = false
                self.setNeedsStatusBarAppearanceUpdate()
            }
            .addDisposableTo(self.disposeBag)
        
        let wrappedNC = XGNavigationController(rootViewController: filterVC)
        wrappedNC.navigationBar.backgroundColor = nil
        wrappedNC.navigationBar.barTintColor = nil
        wrappedNC.navigationBar.tintColor = nil
        wrappedNC.navigationBar.titleTextAttributes = nil
        wrappedNC.modalPresentationStyle = .OverFullScreen
        
        self.presentViewController(wrappedNC, animated: true) {
            self.useDefaultStatusBarStyle = true
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

}


extension XGExplorerViewController: XGFilterViewControllerDelegate {
    
    func filterViewControllerDidChangeValue(vc: XGFilterViewController) {
        self.tableViewController.selectedOrderType = vc.selectedOrderType
        self.tableViewController.selectedTag = vc.selectedTag
        
        self.tableViewController.reload()
    }
    
}