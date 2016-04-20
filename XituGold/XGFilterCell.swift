//
//  XGFilterCell.swift
//  XituGold
//
//  Created by 杨弘宇 on 16/4/17.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class XGFilterCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectedView: UIView!
        
    override var selected: Bool {
        didSet {
            if self.selected {
                self.label.textColor = UIColor.whiteColor()
                self.selectedView.hidden = false
            } else {
                self.label.textColor = UIColor.blackColor()
                self.selectedView.hidden = true
            }
        }
    }

}
