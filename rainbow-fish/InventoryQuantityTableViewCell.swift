//
//  InventoryQuantityTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/4/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class InventoryQuantityTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var inventoryQuantityField: UITextField!
    @IBOutlet fileprivate weak var stepper: UIStepper!
    
    let numberFormatter = NumberFormatter()

    var quantity: NSDecimalNumber = NSDecimalNumber(value: 0 as Int) {
        didSet {
            let decimal = numberFormatter.number(from: self.quantity.stringValue) as? NSDecimalNumber
            if decimal != nil {
                self.stepper.value = decimal?.doubleValue ?? 0.0
                self.inventoryQuantityField.clearsOnBeginEditing = (decimal?.intValue == 0)
            }
        }
    }
    
    var lineItem: Inventory? {
        didSet {
            self.quantity = lineItem?.quantity ?? NSDecimalNumber(value: 0 as Int)
            self.inventoryQuantityField.text = self.quantity.stringValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.inventoryQuantityField.font = AppearanceManager.appearanceManager.standardFont
        self.inventoryQuantityField.textColor = AppearanceManager.appearanceManager.blackColor
        self.inventoryQuantityField.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.inventoryQuantityField.text = "0"
        self.inventoryQuantityField.delegate = self;
        
        let inputAccessory = DoneEditingInputAccessoryView(frame: CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: 34.0))
        self.inventoryQuantityField.inputAccessoryView = inputAccessory
        inputAccessory.delegate = self
        
        self.stepper.tintColor = AppearanceManager.appearanceManager.brandColor
        self.stepper.addTarget(self, action: #selector(InventoryQuantityTableViewCell.stepperValueDidChange(_:)), for: .touchUpInside)
        numberFormatter.generatesDecimalNumbers = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.inventoryQuantityField.resignFirstResponder()
    }
    
    // MARK: stepper action handler
    
    func stepperValueDidChange(_ sender: UIStepper) {
        self.quantity = NSDecimalNumber(value: sender.value as Double)
        self.lineItem?.quantity = self.quantity
        self.inventoryQuantityField.text = self.quantity.stringValue
    }
    
    // MARK: class methods
    
    class var preferredRowSize: CGFloat { return 46.0 }
    
    class var nibName: String { return "InventoryQuantityTableViewCell" }
    
}


extension InventoryQuantityTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let nsText: NSString = textField.text! as NSString
        
        let existingDecimalRange = nsText.range(of: ".")
        if existingDecimalRange.location != NSNotFound && string == "." {
            return false
        }
        let valueString = nsText.replacingCharacters(in: range, with: string) as String
        
        if valueString.lengthOfBytes(using: String.Encoding.utf8) == 0 {
            self.quantity = NSDecimalNumber(value: 0 as Int32)
            return true
        }
        
        let regex = (try? NSRegularExpression(pattern: "^(\\d*)\\.?\\d*", options: NSRegularExpression.Options())) as NSRegularExpression!
        
        if let matchResult = regex?.firstMatch(in: valueString, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, valueString.lengthOfBytes(using: String.Encoding.utf8))) {
            let matchRange = matchResult.rangeAt(0)
            let nsStr = valueString as NSString
            let matchString = nsStr.substring(with: matchRange)
            self.quantity = NSDecimalNumber(string: matchString)
            self.lineItem?.quantity = self.quantity
            return true
        }
        return false
    }
}

extension InventoryQuantityTableViewCell: DoneEditingInputAccessoryDelegate {
    
    func doneEditingInputAccessoryDoneButtonTapped(_ inputAccessory: DoneEditingInputAccessoryView) {
        self.inventoryQuantityField.resignFirstResponder()
    }
    
}

