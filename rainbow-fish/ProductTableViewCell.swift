//
//  ProductTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/1/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.accessoryType = .DisclosureIndicator
        self.separatorInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 0)
        self.selectedBackgroundView = UIView(frame: self.bounds)
        self.selectedBackgroundView.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        titleLabel.font = AppearanceManager.appearanceManager.standardFont
        titleLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
    }
 
    // MARK: class methods
    
    class var estimatedRowHeight: CGFloat {
        return CGFloat(44.0)
    }
    
    class var nibName: String {
        return "ProductTableViewCell"
    }
    
}
