//
//  PencilColorTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/22/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilColorTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var colorLabel: UILabel!
    @IBOutlet private weak var swatchView: UIView!

    var colorName: String? {
        didSet {
            self.colorLabel.text = self.colorName ?? "#000000"
        }
    }
    
    var swatchColor: UIColor? {
        didSet {
            self.swatchView.backgroundColor = self.swatchColor ?? UIColor.blackColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.colorLabel.textColor = AppearanceManager.appearanceManager.brandColor
        self.colorLabel.font = AppearanceManager.appearanceManager.nameLabelFont
        self.swatchView.layer.borderWidth = 1.0
        self.swatchView.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    class var nibName: String { return "PencilColorTableViewCell" }
    
}
