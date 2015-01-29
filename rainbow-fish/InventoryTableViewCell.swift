//
//  PencilTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/26/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
import QuartzCore

class InventoryTableViewCell: UITableViewCell {

    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet weak var colorSwatchImageView: UIImageView!
    
    var titleColor: UIColor {
        get {
            return self.titleLabel.textColor
        }
        set {
            self.titleLabel.textColor = newValue
        }
    }
    
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
    
    var subtitle: String? {
        get {
            return self.subTitleLabel.text
        }
        set {
            self.subTitleLabel.text = newValue
        }
    }
    var quantity: String? {
        get {
            return self.quantityLabel.text
        }
        set {
            self.quantityLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .DisclosureIndicator
        self.selectedBackgroundView = UIView(frame: self.bounds)
        self.selectedBackgroundView.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.quantityLabel.font = AppearanceManager.appearanceManager.standardFont
        self.quantityLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        
        self.titleLabel.font = AppearanceManager.appearanceManager.standardFont
        self.titleLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        
        self.subTitleLabel.font = AppearanceManager.appearanceManager.subtitleFont
        self.subTitleLabel.textColor = AppearanceManager.appearanceManager.subTitleColor
        
        self.colorSwatchImageView.layer.cornerRadius = 10.0;
        self.colorSwatchImageView.layer.borderColor = AppearanceManager.appearanceManager.blackColor.CGColor;
        self.colorSwatchImageView.layer.borderWidth = 1.0;
        
    }
    
    // MARK: class methods
    
    class var estimatedRowHeight: CGFloat {
        return CGFloat(60.0)
    }
    
    class var nibName: String {
        return "InventoryTableViewCell"
    }
}
