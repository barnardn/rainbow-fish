//
//  DefaultDetailTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/8/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class DefaultDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel?.textColor = AppearanceManager.appearanceManager.bodyTextColor
        self.detailTextLabel?.textColor = AppearanceManager.appearanceManager.brandColor
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.selectedBackgroundView = UIView(frame: CGRectZero)
        self.selectedBackgroundView?.backgroundColor = AppearanceManager.appearanceManager.selectedCellBackgroundColor
    }
    
    class var nibName: String { return "DefaultDetailTableViewCell" }
}
