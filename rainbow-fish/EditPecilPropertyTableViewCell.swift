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

    @IBOutlet fileprivate weak var textfield: UITextField!
    
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
                self.textfield.text = self.pencil.value(forKeyPath: keypath) as! String?
            }
        }
    }

    var keyPath: String! {
        didSet {
            if self.pencil != nil {
                self.textfield.text = self.pencil.value(forKeyPath: self.keyPath) as! String?
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textfield.delegate = self
        self.textfield.font = AppearanceManager.appearanceManager.standardFont
        self.textfield.textColor = AppearanceManager.appearanceManager.bodyTextColor
        self.textfield.backgroundColor = UIColor.white
        self.textfield.tintColor = AppearanceManager.appearanceManager.brandColor
        self.shouldIndentWhileEditing = false
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.textfield.becomeFirstResponder()
        } else {
            self.textfield.resignFirstResponder()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return self.textfield.becomeFirstResponder()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.textfield.isEnabled = editing
    }
    
    class var nibName: String {
        return "EditPecilPropertyTableViewCell"
    }
    
}

extension EditPecilPropertyTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let keypath = self.keyPath {
            if let pencil = self.pencil {
                let end = textField.text!.characters.index(textField.text!.startIndex, offsetBy: range.location)
                let replaceRange: Range<String.Index> = Range<String.Index>(textField.text!.startIndex ..< end)
//                let replaceRange: Range<String.Index> = Range<String.Index>(start: textField.text!.startIndex, end: end)
                let value = textfield.text!.substring(with: replaceRange) + string
                pencil.setValue(value, forKey: keypath)
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return false
    }
    
}
