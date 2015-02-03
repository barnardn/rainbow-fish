//
//  ProductHeaderView.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/1/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class ProductHeaderView: UITableViewHeaderFooterView {

    private weak var titleLabel: UILabel!
    
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
    
    override init(reuseIdentifier: String?) {
        self.titleLabel = UILabel(frame: CGRectZero)
        
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.font = AppearanceManager.appearanceManager.subtitleFont
        self.titleLabel.textColor = AppearanceManager.appearanceManager.subTitleColor
        self.contentView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), ProductHeaderView.headerHeight)
    }
    
    class var headerHeight: CGFloat {
        return 24.0
    }
    
}
