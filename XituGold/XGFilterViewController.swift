//
//  XGFilterViewController.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol XGFilterViewControllerDelegate: NSObjectProtocol {
    
    func filterViewControllerDidChangeValue(vc: XGFilterViewController)
    
}


class XGFilterViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    var selectedOrderType = 0
    var selectedTag = 0
    
    weak var delegate: XGFilterViewControllerDelegate?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
        doneButtonItem.rx_tap
            .subscribeNext { [unowned self] in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)
        
        self.navigationItem.title = "筛选"
        self.navigationItem.rightBarButtonItems = [doneButtonItem]

        self.view.backgroundColor = UIColor.clearColor()
        
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        backgroundView.frame = self.view.bounds
        self.view.addSubview(backgroundView)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 70, height: 40)
        flowLayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 30)
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.contentInset = UIEdgeInsets(top: 80, left: 30, bottom: 0, right: 30)
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.view.addSubview(self.collectionView)
        
        self.collectionView.registerNib(UINib(nibName: "XGFilterCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.collectionView.registerNib(UINib(nibName: "XGGroupTitleReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: self.selectedOrderType, inSection: 0), animated: true, scrollPosition: .None)
        self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: self.selectedTag, inSection: 1), animated: true, scrollPosition: .None)
    }

}


extension XGFilterViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 2 : XGTagNames.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! XGFilterCell
        
        if indexPath.section == 0 {
            cell.label.text = indexPath.item == 0 ? "热门" : "最新"
        } else {
            cell.label.text = XGTagNames[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! XGGroupTitleReusableView
        
        view.label.text = indexPath.section == 0 ? "排序方式" : "标签"
        
        return view
    }
    
}


extension XGFilterViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let indexPaths = collectionView.indexPathsForSelectedItems() {
            if let indexPath = indexPaths.filter({ $0.section == indexPath.section && $0.item != indexPath.item }).first {
                collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            }
        }
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.selectedOrderType = indexPath.item
        } else {
            self.selectedTag = indexPath.item
        }
        
        self.delegate?.filterViewControllerDidChangeValue(self)
    }
    
}
