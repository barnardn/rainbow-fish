//
//  EditPecilPropertyTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/10/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CoreData
import UIKit

class EditPecilPropertyTableViewCell: UITableViewCell {

    @IBOutlet private weak var textfield: UITextField!
    
    var placeholder: String? {
        get {
            return self.textfield.placeholder
        }
        set {
            self.textfield.placeholder = newValue
        }
    }
    
    var pencil: Pencil! {
        didSet {
            if let keypath = self.keyPath {
                self.textfield.text = self.pencil.valueForKeyPath(keypath) as String?
            }
        }
    }

    var keyPath: String! {
        didSet {
            if self.pencil != nil {
                self.textfield.text = self.pencil.valueForKeyPath(self.keyPath) as String?
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textfield.delegate = self
        self.textfield.font = AppearanceManager.appearanceManager.standardFont
        self.textfield.textColor = AppearanceManager.appearanceManager.bodyTextColor
        self.textfield.backgroundColor = UIColor.whiteColor()
        self.textfield.tintColor = AppearanceManager.appearanceManager.brandColor
        self.selectionStyle = .None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.textfield.becomeFirstResponder()
        } else {
            self.textfield.resignFirstResponder()
        }
    }
    
    
    class var nibName: String {
        return "EditPecilPropertyTableViewCell"
    }
    
}

extension EditPecilPropertyTableViewCell: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let keypath = self.keyPath {
            if let pencil = self.pencil {
                var value = textfield.text + string
                pencil.setValue(value, forKey: keypath)
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return false
    }
    
}