//
//  PencilColorTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/22/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilColorTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var colorLabel: UILabel!
    @IBOutlet fileprivate weak var swatchView: UIView!

    var colorName: String? {
        didSet {
            self.colorLabel.text = self.colorName ?? "#000000"
        }
    }
    
    var swatchColor: UIColor? {
        didSet {
            self.swatchView.backgroundColor = self.swatchColor ?? UIColor.black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.colorLabel.textColor = AppearanceManager.appearanceManager.brandColor
        self.colorLabel.font = AppearanceManager.appearanceManager.nameLabelFont
        self.swatchView.layer.borderWidth = 1.0
        self.swatchView.layer.borderColor = UIColor.black.cgColor
    }
    
    class var nibName: String { return "PencilColorTableViewCell" }
    
}
