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
        self.layer.shadowColor = UIColor.black.cgColor

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}


class HintView: UIView {
    
    fileprivate var contentView: HintContentView!
    fileprivate var dismissTapGestureRecognizer =  UITapGestureRecognizer()
    
    var configuration = HintViewConfiguration() {
        didSet {
            self.contentView.backgroundColor = configuration.backgroundColor
            self.contentView.titleLabel.textColor = configuration.titleColor
            self.contentView.titleLabel.font = configuration.titleFont
            self.contentView.messageTextView.isEditable = true
            self.contentView.messageTextView.font = configuration.textFont
            self.contentView.messageTextView.textColor = configuration.textColor
            self.contentView.messageTextView.isEditable = false
            self.contentView.frame = CGRect(x: configuration.margins.width, y: -configuration.size.height, width: configuration.size.width - (2 * configuration.margins.width), height: configuration.size.height + configuration.margins.height)
        }
    }
    
    class var defaultView: HintView {
        struct Singleton {
            static let instance = HintView(frame: UIScreen.main.bounds)
        }
        return Singleton.instance
    }
    
    class func show(title: String, hint: String) {
        let currentWindow : UIWindow = UIApplication.shared.windows.last as UIWindow!
        let hintView = HintView.defaultView
        if hintView.superview == nil {
            currentWindow.addSubview(hintView)
            hintView.animateToVisible(title: title, hint: hint)
        } else {
            hintView.animateTextChanges(title: title, hint: hint)
        }
    }
    
    class func hide() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                HintView.defaultView.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                HintView.defaultView.removeFromSuperview()
        }) 
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        self.dismissTapGestureRecognizer.addTarget(self, action: #selector(HintView.dismissTapGestureRecognizerDidTap(_:)))
        self.addGestureRecognizer(self.dismissTapGestureRecognizer)
        self.contentView = UINib(nibName: "HintView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! HintContentView
        self.addSubview(self.contentView);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func dismissTapGestureRecognizerDidTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        HintView.hide()
    }
    
    fileprivate func animateToVisible(title: String, hint: String) {
        self.contentView.title = title
        self.contentView.hintText = hint
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.contentView.transform = CGAffineTransform(translationX: 0.0, y: self.configuration.size.height + self.configuration.margins.height)
        }) 
    }
    
    fileprivate func animateTextChanges(title: String, hint: String) {
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModePaced, animations: { () -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: { () -> Void in
                self.contentView.titleLabel.alpha = 0.0
                self.contentView.messageTextView.alpha = 0.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { () -> Void in
                self.contentView.title = title
                self.contentView.hintText = hint
                self.contentView.titleLabel.alpha = 1.0
                self.contentView.messageTextView.alpha = 1.0
            })
            
        }, completion: nil)
        
    }
    
    
    
}

struct HintViewConfiguration {
    
    var backgroundColor = UIColor.blue
    var titleColor = UIColor.white
    var textColor = UIColor.white
    var titleFont = UIFont.systemFont(ofSize: 17.0)
    var textFont = UIFont.systemFont(ofSize: 14.0)
    var margins = CGSize(width: 20.0, height: 20.0)
    var size = CGSize(width: 300.0, height: 284.0)
}


