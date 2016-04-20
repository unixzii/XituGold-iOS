//
//  XGLoadableImageView.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/20.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class XGLoadableImageView: UIImageView {

    var imageURL = PublishSubject<NSURL>()
    var placeholderImage: UIImage?
    var errorImage: UIImage?
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.imageURL.subscribeNext { [unowned self] in
            self.fetchAndSetImageWithURL($0)
        }.addDisposableTo(self.disposeBag)
    }
    
    func fetchAndSetImageWithURL(URL: NSURL) {
        if let cachedImage = XGImageCacheController.sharedController.imageForKey(URL) {
            self.image = cachedImage
            return
        }
        
        SMNetworkActivityController.sharedController.startActivity()
        
        NSURLSession.sharedSession().rx_data(NSURLRequest(URL: URL))
            .takeUntil(self.imageURL)
            .retry(2)
            .map { UIImage(data: $0) }
            .catchErrorJustReturn(self.errorImage)
            .startWith(self.placeholderImage)
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                SMNetworkActivityController.sharedController.endActivity()
                if $0 != nil {
                    XGImageCacheController.sharedController.putImage($0!, forKey: URL)
                }
                self?.image = $0
            }
            .addDisposableTo(self.disposeBag)
    }
    
}
