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
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        var label = UILabel(frame: CGRectZero)
        
        self.contentView.addSubview(label)
        label.font = AppearanceManager.appearanceManager.subtitleFont
        label.textColor = AppearanceManager.appearanceManager.subTitleColor
        self.contentView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.titleLabel = label;
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.titleLabel.frame = CGRectMake(10, 0, CGRectGetWidth(self.bounds), ProductHeaderView.headerHeight)
    }
    
    class var headerHeight: CGFloat {
        return 24.0
    }
    
}
