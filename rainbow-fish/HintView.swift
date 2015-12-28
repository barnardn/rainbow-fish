//
//  HintView.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 12/8/15.
//  Copyright © 2015 Clamdango. All rights reserved.
//

import UIKit

class HintContentView: UIView {
    
    @IBOutlet  weak var titleLabel: UILabel!
    @IBOutlet  weak var messageTextView: UITextView!
    
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
    
    var hintText: String? {
        get {
            return self.messageTextView.text;
        }
        set {
            self.messageTextView.text = newValue;
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5.0
        self.layer.shadowColor = UIColor.blackColor().CGColor

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}


class HintView: UIView {
    
    private var contentView: HintContentView!
    private var dismissTapGestureRecognizer =  UITapGestureRecognizer()
    
    var configuration = HintViewConfiguration() {
        didSet {
            self.contentView.backgroundColor = configuration.backgroundColor
            self.contentView.titleLabel.textColor = configuration.titleColor
            self.contentView.titleLabel.font = configuration.titleFont
            self.contentView.messageTextView.editable = true
            self.contentView.messageTextView.font = configuration.textFont
            self.contentView.messageTextView.textColor = configuration.textColor
            self.contentView.messageTextView.editable = false
            self.contentView.frame = CGRect(x: configuration.margins.width, y: -configuration.size.height, width: configuration.size.width - (2 * configuration.margins.width), height: configuration.size.height + configuration.margins.height)
        }
    }
    
    class var defaultView: HintView {
        struct Singleton {
            static let instance = HintView(frame: UIScreen.mainScreen().bounds)
        }
        return Singleton.instance
    }
    
    class func show(title title: String, hint: String) {
        let currentWindow : UIWindow = UIApplication.sharedApplication().windows.last as UIWindow!
        let hintView = HintView.defaultView
        if hintView.superview == nil {
            currentWindow.addSubview(hintView)
            hintView.animateToVisible(title: title, hint: hint)
        } else {
            hintView.animateTextChanges(title: title, hint: hint)
        }
    }
    
    class func hide() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
                HintView.defaultView.alpha = 0.0
            }) { (finished: Bool) -> Void in
                HintView.defaultView.removeFromSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        self.dismissTapGestureRecognizer.addTarget(self, action: Selector("dismissTapGestureRecognizerDidTap:"))
        self.addGestureRecognizer(self.dismissTapGestureRecognizer)
        self.contentView = UINib(nibName: "HintView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! HintContentView
        self.addSubview(self.contentView);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func dismissTapGestureRecognizerDidTap(tapGestureRecognizer: UITapGestureRecognizer) {
        HintView.hide()
    }
    
    private func animateToVisible(title title: String, hint: String) {
        self.contentView.title = title
        self.contentView.hintText = hint
        UIView.animateWithDuration(0.5) { () -> Void in
            self.contentView.transform = CGAffineTransformMakeTranslation(0.0, self.configuration.size.height + self.configuration.margins.height)
        }
    }
    
    private func animateTextChanges(title title: String, hint: String) {
        
        UIView.animateKeyframesWithDuration(0.5, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                self.contentView.titleLabel.alpha = 0.0
                self.contentView.messageTextView.alpha = 0.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                self.contentView.title = title
                self.contentView.hintText = hint
                self.contentView.titleLabel.alpha = 1.0
                self.contentView.messageTextView.alpha = 1.0
            })
            
        }, completion: nil)
        
    }
    
    
    
}

struct HintViewConfiguration {
    
    var backgroundColor = UIColor.blueColor()
    var titleColor = UIColor.whiteColor()
    var textColor = UIColor.whiteColor()
    var titleFont = UIFont.systemFontOfSize(17.0)
    var textFont = UIFont.systemFontOfSize(14.0)
    var margins = CGSize(width: 20.0, height: 20.0)
    var size = CGSize(width: 300.0, height: 284.0)
}


