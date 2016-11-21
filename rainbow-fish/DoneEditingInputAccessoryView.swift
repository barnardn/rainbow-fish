//
//  DoneEditingInputAccessoryView.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

protocol DoneEditingInputAccessoryDelegate {
    func doneEditingInputAccessoryDoneButtonTapped(_ inputAccessory: DoneEditingInputAccessoryView)
}

class DoneEditingInputAccessoryView: UIView {

    var delegate: DoneEditingInputAccessoryDelegate?
    lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        button.setTitle(NSLocalizedString("Done", comment:"quantity input accessory done button title"), for: UIControlState())
        button.setTitleColor(AppearanceManager.appearanceManager.brandColor, for: UIControlState())
        button.addTarget(self, action: #selector(DoneEditingInputAccessoryView.doneButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var topLine: UIView = {
        let view =  UIView(frame: CGRect.zero)
        view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        return view
    }()

    lazy var bottomLine: UIView = {
        let view =  UIView(frame: CGRect.zero)
        view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(self.doneButton)
        self.addSubview(self.topLine)
        self.addSubview(self.bottomLine)
    }

    func doneButtonTapped(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.doneEditingInputAccessoryDoneButtonTapped(self)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topLine.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: 1.0)
        let size = self.doneButton.frame.size
        self.doneButton.frame = CGRect(x: self.bounds.width - size.width, y: 1.0, width: size.width, height: self.bounds.height - 2.0)
        self.bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height, width: self.bounds.width, height: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
