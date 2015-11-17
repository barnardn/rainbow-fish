//
//  NameValueTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class NameValueTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    var name: String? {
        get {
            return self.nameLabel.text
        }
        set {
            self.nameLabel.text = newValue
            self.setNeedsUpdateConstraints()
        }
    }
    
    var value: String? {
        get {
            return self.valueLabel.text
        }
        set {
            self.valueLabel.text = newValue
            self.setNeedsUpdateConstraints()
        }
    }
    
    var disabledAppearance: Bool = false {
        willSet(newValue) {
            self.contentView.alpha = (newValue) ? CGFloat(0.5) : CGFloat(1.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.disabledAppearance = false
        self.selectedBackgroundView = UIView(frame: self.bounds)
        self.selectedBackgroundView?.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
        self.nameLabel.textColor = AppearanceManager.appearanceManager.brandColor
        self.nameLabel.font = AppearanceManager.appearanceManager.nameLabelFont
        self.valueLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        self.valueLabel.font = AppearanceManager.appearanceManager.standardFont
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.alpha = 1.0
    }
    
    // MARK: class methods
    
    class var nibName: String {
        return "NameValueTableViewCell"
    }
    
}
