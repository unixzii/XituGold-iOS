//
//  XGTagViewController.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import RxSwift

class XGTagViewController: UIViewController {

    var tags = [XGTag]()
    
    var collectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "标签"
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.view.bounds.width / 2.0, height: 150)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.view.addSubview(self.collectionView)
        
        self.collectionView.registerNib(UINib(nibName: "XGTagCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        reload()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reload() {
        self.tags.removeAll()
        
        XGTagAPI.fetchTags()
            .subscribe { [unowned self] event in
                if event.element != nil {
                    self.tags.appendContentsOf(event.element!)
                    self.collectionView.reloadData()
                }
                
                if event.error != nil {
                    self.showAlertWithTitle("网络问题", message: "无法连接到服务器，请检查网络设置。")
                }
            }
            .addDisposableTo(self.disposeBag)
    }
    
}


extension XGTagViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! XGTagCell
        
        let tag = self.tags[indexPath.item]
        
        cell.titleLabel.text = tag.title
        cell.iconImageView.imageURL.onNext(tag.icon ?? NSURL())
        cell.subcLabel.text = "\(tag.subscribersCount) 关注"
        cell.entLabel.text = "\(tag.entriesCount) 文章"
        
        return cell
    }
    
}


extension XGTagViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = XGEntryTableViewController()
        vc.navigationItem.title = self.tags[indexPath.item].title
        vc.selectedDTag = self.tags[indexPath.item].objectRef
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        dispatch_async(dispatch_get_main_queue()) { 
            vc.reload()
        }
    }
    
}
