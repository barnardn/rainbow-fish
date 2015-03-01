//
//  PencilTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/1/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilTableViewCell: UITableViewCell {

    @IBOutlet private weak var colorSwatchImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var pencilCodeLabel: UILabel!
    @IBOutlet private weak var centerYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet private weak var inventoryStatusLabel: UILabel!
    
    var name: String? {
        get {
            return self.nameLabel.text
        }
        set {
            self.nameLabel.text = newValue
        }
    }
    
    var pencilIdentifier: String? {
        get {
            return self.pencilCodeLabel.text
        }
        set {
            self.pencilCodeLabel.text = newValue
        }
    }
    
    var colorSwatch: UIColor? {
        get {
            return self.colorSwatchImageView.backgroundColor
        }
        set {
            self.colorSwatchImageView.backgroundColor = newValue
        }
    }
    
    var presentInInventory: Bool = false {
        didSet {
            self.inventoryStatusLabel.hidden = !self.presentInInventory
            if self.presentInInventory {
                self.centerYAlignmentConstraint.constant = 5.0
            } else {
                self.centerYAlignmentConstraint.constant = 0
            }
            self.setNeedsUpdateConstraints()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .DisclosureIndicator
        self.selectedBackgroundView = UIView(frame: self.bounds)
        self.separatorInset = UIEdgeInsets(top: 0, left: 35.0, bottom: 0, right: 0)
        self.selectedBackgroundView.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        self.nameLabel.font = AppearanceManager.appearanceManager.standardFont
        self.nameLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        
        self.pencilCodeLabel.font = AppearanceManager.appearanceManager.subtitleFont
        self.pencilCodeLabel.textColor = AppearanceManager.appearanceManager.subTitleColor
        
        self.inventoryStatusLabel.font = AppearanceManager.appearanceManager.subtitleFont
        self.inventoryStatusLabel.textColor = AppearanceManager.appearanceManager.brandColor
        
        self.colorSwatchImageView.layer.cornerRadius = 10.0;
        self.colorSwatchImageView.layer.borderColor = AppearanceManager.appearanceManager.blackColor.CGColor
        self.colorSwatchImageView.layer.borderWidth = 1.0;
    }

    class var nibName: String { return "PencilTableViewCell" }
    
    class var rowHeight: CGFloat { return 50.0 }
    
}
