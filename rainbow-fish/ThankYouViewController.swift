//
//  ThankYouViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 7/11/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class ThankYouViewController: UIViewController {

    @IBOutlet private weak var normImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageTextView: UITextView!
    @IBOutlet private weak var okButton: UIButton!
    
    private var message = ""
    
    convenience init(message: String!) {
        self.init(nibName: "ThankYouView", bundle: nil)
        self.message = message
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.normImageView.image = UIImage(named: "developer")
        self.normImageView.layer.cornerRadius = CGRectGetWidth(self.normImageView.frame) / 2.0
        self.normImageView.clipsToBounds = true
        self.titleLabel.text = NSLocalizedString("From the Developer...", comment:"developer view title")
        self.titleLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        self.messageTextView.text = message
        self.messageTextView.textColor = AppearanceManager.appearanceManager.bodyTextColor
        self.okButton.setTitle(NSLocalizedString("OK", comment:"developer view ok button title"), forState: .Normal)
        okButton.setTitleColor(AppearanceManager.appearanceManager.brandColor, forState: .Normal)
        self.okButton.addTarget(self, action: Selector("okButtonTapped:"), forControlEvents: .TouchUpInside)
    }

    func okButtonTapped(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
