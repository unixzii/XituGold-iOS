//
//  XGEntryCell.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import RxSwift

class XGEntryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readsLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var collectionLabel: UILabel!
    @IBOutlet weak var screenShotImageView: XGLoadableImageView!
    @IBOutlet weak var screenShotImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var screenShotImageViewRatioConstraint: NSLayoutConstraint!
        
    func collapseImageView(collapse: Bool) {
        if collapse {
            self.screenShotImageViewRatioConstraint.active = false
            self.screenShotImageViewWidthConstraint.active = true
        } else {
            self.screenShotImageViewWidthConstraint.active = false
            self.screenShotImageViewRatioConstraint.active = true
        }
        
        self.setNeedsLayout()
    }
    
}
