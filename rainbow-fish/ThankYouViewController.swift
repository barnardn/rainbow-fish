//
//  ThankYouViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 7/11/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class ThankYouViewController: UIViewController {

    @IBOutlet fileprivate weak var normImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var messageTextView: UITextView!
    @IBOutlet fileprivate weak var okButton: UIButton!
    
    fileprivate var message = ""
    
    convenience init(message: String!) {
        self.init(nibName: "ThankYouView", bundle: nil)
        self.message = message
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.normImageView.image = UIImage(named: "developer")
        self.normImageView.layer.cornerRadius = self.normImageView.frame.width / 2.0
        self.normImageView.clipsToBounds = true
        self.titleLabel.text = NSLocalizedString("From the Developer...", comment:"developer view title")
        self.titleLabel.textColor = AppearanceManager.appearanceManager.bodyTextColor
        self.messageTextView.text = message
        self.messageTextView.textColor = AppearanceManager.appearanceManager.bodyTextColor
        self.okButton.setTitle(NSLocalizedString("OK", comment:"developer view ok button title"), for: UIControlState())
        okButton.setTitleColor(AppearanceManager.appearanceManager.brandColor, for: UIControlState())
        self.okButton.addTarget(self, action: #selector(ThankYouViewController.okButtonTapped(_:)), for: .touchUpInside)
    }

    func okButtonTapped(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
