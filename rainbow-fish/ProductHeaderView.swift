//
//  ProductHeaderView.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/1/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class ProductHeaderView: UITableViewHeaderFooterView {

    fileprivate weak var titleLabel: UILabel!
    
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue?.uppercased()
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let label = UILabel(frame: CGRect.zero)
        
        self.contentView.addSubview(label)
        label.font = AppearanceManager.appearanceManager.nameLabelFont
        label.textColor = AppearanceManager.appearanceManager.tableHeaderColor
        self.contentView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.titleLabel = label;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.titleLabel.frame = CGRect(x: 10, y: 0, width: self.bounds.width, height: ProductHeaderView.headerHeight)
    }
    
    class var headerHeight: CGFloat {
        return 34.0
    }
    
}
