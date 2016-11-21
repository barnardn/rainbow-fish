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

    @IBOutlet fileprivate weak var quantityLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var subTitleLabel: UILabel!
    @IBOutlet fileprivate weak var colorSwatchView: UIView!
    
    fileprivate var _swatchColor: UIColor?
    
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
    
    var swatchColor: UIColor? {
        get {
            return self.colorSwatchView.backgroundColor
        }
        set {
            self.colorSwatchView.backgroundColor = newValue
            self._swatchColor = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .disclosureIndicator
        self.selectedBackgroundView = UIView(frame: self.bounds)
        self.separatorInset = UIEdgeInsets(top: 0, left: 35.0, bottom: 0, right: 0)
        self.selectedBackgroundView?.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
        self.contentView.backgroundColor = UIColor.white
        self.quantityLabel.font = AppearanceManager.appearanceManager.standardFont
        self.quantityLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        
        self.titleLabel.font = AppearanceManager.appearanceManager.standardFont
        self.titleLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        
        self.subTitleLabel.font = AppearanceManager.appearanceManager.subtitleFont
        self.subTitleLabel.textColor = AppearanceManager.appearanceManager.subTitleColor
        
        self.colorSwatchView.layer.cornerRadius = 10.0;
        self.colorSwatchView.layer.borderColor = AppearanceManager.appearanceManager.blackColor.cgColor;
        self.colorSwatchView.layer.borderWidth = 1.0;
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if let color = self._swatchColor {
            self.colorSwatchView.backgroundColor = color
        }
    }
    
    // MARK: class methods
    
    class var estimatedRowHeight: CGFloat {
        return CGFloat(60.0)
    }
    
    class var nibName: String {
        return "InventoryTableViewCell"
    }
}
