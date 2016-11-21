//
//  PencilTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/1/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var colorSwatchImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var pencilCodeLabel: UILabel!
    @IBOutlet fileprivate weak var centerYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var inventoryStatusLabel: UILabel!
    fileprivate var _colorSwatch: UIColor?
    
    
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
            self._colorSwatch = newValue
        }
    }
    
    var presentInInventory: Bool = false {
        didSet {
            self.inventoryStatusLabel.isHidden = !self.presentInInventory
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
        self.accessoryType = .disclosureIndicator
        self.selectedBackgroundView = UIView(frame: self.bounds)
        self.separatorInset = UIEdgeInsets(top: 0, left: 35.0, bottom: 0, right: 0)
        self.selectedBackgroundView?.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
        self.contentView.backgroundColor = UIColor.white
        
        self.nameLabel.font = AppearanceManager.appearanceManager.standardFont
        self.nameLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        
        self.pencilCodeLabel.font = AppearanceManager.appearanceManager.subtitleFont
        self.pencilCodeLabel.textColor = AppearanceManager.appearanceManager.subTitleColor
        
        self.inventoryStatusLabel.font = AppearanceManager.appearanceManager.subtitleFont
        self.inventoryStatusLabel.textColor = AppearanceManager.appearanceManager.brandColor
        
        self.colorSwatchImageView.layer.cornerRadius = 10.0;
        self.colorSwatchImageView.layer.borderColor = AppearanceManager.appearanceManager.blackColor.cgColor
        self.colorSwatchImageView.layer.borderWidth = 1.0;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if let color = self._colorSwatch {
            self.colorSwatchImageView.backgroundColor = color
        }
    }
    
    
    class var nibName: String { return "PencilTableViewCell" }
    
    class var rowHeight: CGFloat { return 50.0 }
    
}
