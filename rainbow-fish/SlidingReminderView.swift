//
//  SlidingReminderView.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 11/22/15.
//  Copyright © 2015 Clamdango. All rights reserved.
//

import UIKit

class SlidingReminderView: UIView {

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppearanceManager.appearanceManager.brandColor
        titleLabel.text = NSLocalizedString("Hint", comment:"sliding reminder view title")
        titleLabel.font = AppearanceManager.appearanceManager.headlineFont
        titleLabel.textColor = UIColor.yellowColor()
        messageTextView.backgroundColor = AppearanceManager.appearanceManager.brandColor
        messageTextView.font = AppearanceManager.appearanceManager.standardFont
        messageTextView.text = NSLocalizedString("Add pencils to your \"My Pencils\" inventory by selecting a pencil from the \"Catalog\", then tap the \"Add Pencil to My Inventory\" button.", comment:"invenory hint")
        messageTextView.textColor = UIColor.whiteColor()
        closeButton.setImage(UIImage(named: "icon-close")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = UIColor.whiteColor()
        
    }
    
    
}
