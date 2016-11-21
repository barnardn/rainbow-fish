//
//  TextFieldTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/21/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

protocol TextFieldTableViewCellDelegate: class {
    
    func textFieldTableViewCell(_ cell: TextFieldTableViewCell, changedText: String?)
    
}


class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    var defaultText: String? {
        didSet {
            self.textField.text = self.defaultText
        }
    }
    
    var placeholder: String? {
        didSet {
            self.textField.placeholder = self.placeholder
        }
    }
    
    weak var delegate: TextFieldTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.textField.font = AppearanceManager.appearanceManager.standardFont
        self.textField.textColor = AppearanceManager.appearanceManager.bodyTextColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.textField.becomeFirstResponder()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
    }
    
    class var nibName: String {
        return "TextFieldTableViewCell"
    }
    
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = self.delegate {
            let text: NSString = self.textField.text! as NSString
            delegate.textFieldTableViewCell(self, changedText: text.replacingCharacters(in: range, with: string))
        }
        return true
    }
    
}
