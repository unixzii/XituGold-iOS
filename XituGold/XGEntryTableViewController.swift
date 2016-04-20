//
//  XGEntryTableViewController.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa

class XGEntryTableViewController: UITableViewController {
    
    var entries = [XGEntry]()
    
    var searchController: UISearchController!
    
    var selectedOrderType = 0
    var selectedTag = 0
    var selectedDTag: AnyObject? = nil // Shit, I miscalled that "Category" at the very beginning!!!
    
    private var loading = false
    
    let loadMoreTrigger = PublishSubject<Void>()
    let cancelLoadingTrigger = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.tableView.rowHeight = 90
        self.tableView.registerNib(UINib(nibName: "XGEntryCell", bundle: nil), forCellReuseIdentifier: "EntryCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(reload), forControlEvents: .ValueChanged)
        
        self.loadMoreTrigger
            .throttle(0.2, scheduler: MainScheduler.instance)
            .subscribeNext { [unowned self] in
                self.fetchEntriesSkipped(self.entries.count)
            }
            .addDisposableTo(self.disposeBag)
        
        self.registerForPreviewingWithDelegate(self, sourceView: self.view)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Convenience Methods
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func deselectSelectedRowAnimated(animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: animated)
        }
    }
    
    func makeSafariViewControllerWithEntry(entry: XGEntry) -> SFSafariViewController {
        let vc = SFSafariViewController(URL: entry.URL ?? NSURL())
        vc.view.tintColor = XGGlobalTintColor
        
        return vc
    }
    
    // MARK: -
    
    func reload() {
        self.cancelLoadingTrigger.onNext()
        self.refreshControl?.beginRefreshing()
        self.entries.removeAll()
        self.reloadData()
        self.fetchEntriesSkipped(0)
    }
    
    func fetchEntriesSkipped(skipCount: Int) {
        self.loading = true
        
        var observable: Observable<[XGEntry]>!
        
        if let searchText = self.searchController.searchBar.text where !searchText.isEmpty {
            observable = XGEntryAPI.searchWithKeyword(searchText)
                .takeUntil(self.cancelLoadingTrigger)
        } else {
            var options: [String:AnyObject?] = [
                XGOrderTypeOptionName: self.selectedOrderType,
                XGTagOptionName: self.selectedTag == 0 ? "" : XGTags[self.selectedTag]
            ]
            
            if self.selectedDTag != nil {
                options[XGDTagOptionName] = self.selectedDTag!
            }
            
            observable = XGEntryAPI.fetchEntries(skipCount, withOptions: options)
                .takeUntil(self.cancelLoadingTrigger)
        }
        
        observable.observeOn(MainScheduler.instance)
            .subscribe { [unowned self] event in
                self.loading = false
                self.refreshControl?.endRefreshing()
                
                if event.element != nil {
                    self.entries.appendContentsOf(event.element!)
                    self.reloadData()
                }
                
                if event.error != nil {
                    self.searchController.dismissViewControllerAnimated(true, completion: nil)
                    self.showAlertWithTitle("网络问题", message: "无法连接到服务器，请检查网络设置。")
                }
            }
            .addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EntryCell", forIndexPath: indexPath) as! XGEntryCell
        let entry = self.entries[indexPath.row]
        
        cell.titleLabel.text = entry.title
        cell.readsLabel.text = "\(entry.viewsCount)次浏览"
        cell.commentsLabel.text = "\(entry.commentsCount)条评论"
        cell.createdAtLabel.text = entry.createdAt?.formattedStringFromThenToNow().stringByAppendingString("之前")
        cell.collectionLabel.text = String(entry.collectionCount)
        
        if entry.screenshot == nil {
            cell.collapseImageView(true)
        } else {
            cell.screenShotImageView.imageURL.onNext(entry.screenshot!)
            cell.collapseImageView(false)
        }
        
        return cell
    }
    
    // MARK: - Delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY + scrollView.frame.height + scrollView.contentInset.bottom + 20 > scrollView.contentSize.height {
            self.loadMoreTrigger.onNext()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.deselectSelectedRowAnimated(true)
        
        let vc = self.makeSafariViewControllerWithEntry(self.entries[indexPath.row])
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}


extension XGEntryTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.reload()
    }
    
}


extension XGEntryTableViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = self.tableView.indexPathForRowAtPoint(location) {
            let vc = self.makeSafariViewControllerWithEntry(self.entries[indexPath.row])
            
            previewingContext.sourceRect = self.tableView.cellForRowAtIndexPath(indexPath)?.frame ?? CGRectZero
            
            return vc
        }
        
        return nil
    }

    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        self.presentViewController(viewControllerToCommit, animated: true, completion: nil)
    }
    
}
