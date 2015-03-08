//
//  DoneEditingInputAccessoryView.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

protocol DoneEditingInputAccessoryDelegate {
    func doneEditingInputAccessoryDoneButtonTapped(inputAccessory: DoneEditingInputAccessoryView)
}

class DoneEditingInputAccessoryView: UIView {

    var delegate: DoneEditingInputAccessoryDelegate?
    lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRectZero)
        button.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        button.setTitle(NSLocalizedString("Done", comment:"quantity input accessory done button title"), forState: .Normal)
        button.setTitleColor(AppearanceManager.appearanceManager.brandColor, forState: .Normal)
        button.addTarget(self, action: Selector("doneButtonTapped:"), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var topLine: UIView = {
        let view =  UIView(frame: CGRectZero)
        view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        return view
    }()

    lazy var bottomLine: UIView = {
        let view =  UIView(frame: CGRectZero)
        view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.doneButton)
        self.addSubview(self.topLine)
        self.addSubview(self.bottomLine)
    }

    func doneButtonTapped(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.doneEditingInputAccessoryDoneButtonTapped(self)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topLine.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), 1.0)
        let size = self.doneButton.frame.size
        self.doneButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - size.width, 1.0, size.width, CGRectGetHeight(self.bounds) - 2.0)
        self.bottomLine.frame = CGRectMake(0.0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), 1.0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
