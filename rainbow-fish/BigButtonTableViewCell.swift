//
//  BigButtonTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/1/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class BigButtonTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!

    var disabled: Bool = false {
        didSet {
            if self.disabled {
                self.titleLabel.textColor = AppearanceManager.appearanceManager.disabledTitleColor
            } else {
                self.titleLabel.textColor = AppearanceManager.appearanceManager.brandColor
            }
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
    
    var destructiveButton: Bool = false {
        didSet {
            if self.destructiveButton {
                self.titleLabel.textColor = UIColor.red
                self.selectedBackgroundView?.backgroundColor = UIColor.red
            } else {
                self.titleLabel.textColor = AppearanceManager.appearanceManager.brandColor
                self.selectedBackgroundView?.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = AppearanceManager.appearanceManager.standardFont
        self.titleLabel.textColor = AppearanceManager.appearanceManager.brandColorAlternate
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.titleLabel.textColor = UIColor.white
            return
        }
        if self.disabled {
            self.titleLabel.textColor = AppearanceManager.appearanceManager.disabledTitleColor
        } else {
            self.titleLabel.textColor = (self.destructiveButton) ? UIColor.red : AppearanceManager.appearanceManager.brandColor
        }
    }
    
    class var nibName: String { return "BigButtonTableViewCell" }
    
}
