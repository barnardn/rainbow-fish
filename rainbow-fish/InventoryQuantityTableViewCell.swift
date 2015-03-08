//
//  InventoryQuantityTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/4/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class InventoryQuantityTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var inventoryQuantityField: UITextField!
    @IBOutlet private weak var stepper: UIStepper!
    
    let numberFormatter = NSNumberFormatter()

    var quantity: NSDecimalNumber = NSDecimalNumber(integer: 0) {
        didSet {
            let decimal = numberFormatter.numberFromString(self.quantity.stringValue) as? NSDecimalNumber
            if decimal != nil {
                self.stepper.value = decimal?.doubleValue ?? 0.0
                self.inventoryQuantityField.clearsOnBeginEditing = (decimal?.integerValue == 0)
            }
        }
    }
    
    var lineItem: Inventory? {
        didSet {
            self.quantity = lineItem?.quantity ?? NSDecimalNumber(integer: 0)
            self.inventoryQuantityField.text = self.quantity.stringValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.inventoryQuantityField.font = AppearanceManager.appearanceManager.standardFont
        self.inventoryQuantityField.textColor = AppearanceManager.appearanceManager.blackColor
        self.inventoryQuantityField.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.inventoryQuantityField.text = "0"
        self.inventoryQuantityField.delegate = self;
        
        let inputAccessory = DoneEditingInputAccessoryView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), 34.0))
        self.inventoryQuantityField.inputAccessoryView = inputAccessory
        inputAccessory.delegate = self
        
        self.stepper.tintColor = AppearanceManager.appearanceManager.brandColor
        self.stepper.addTarget(self, action: Selector("stepperValueDidChange:"), forControlEvents: .TouchUpInside)
        numberFormatter.generatesDecimalNumbers = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.inventoryQuantityField.resignFirstResponder()
    }
    
    // MARK: stepper action handler
    
    func stepperValueDidChange(sender: UIStepper) {
        self.quantity = NSDecimalNumber(double: sender.value)
        self.lineItem?.quantity = self.quantity
        self.inventoryQuantityField.text = self.quantity.stringValue
    }
    
    // MARK: class methods
    
    class var preferredRowSize: CGFloat { return 46.0 }
    
    class var nibName: String { return "InventoryQuantityTableViewCell" }
    
}


extension InventoryQuantityTableViewCell: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            if let text = textField.text {
                self.quantity = (text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) ? NSDecimalNumber(int: 0) : NSDecimalNumber(string: text)
            } else {
                self.quantity = NSDecimalNumber(int: 0)
            }
            return true
        }
        var newtext = textField.text + string
        let regex = NSRegularExpression(pattern: "^\\d+(\\.\\d+)?", options: NSRegularExpressionOptions.allZeros, error: nil) as NSRegularExpression!
        let numMatches = regex.numberOfMatchesInString(newtext, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, newtext.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        if numMatches == 1 {
            self.quantity = NSDecimalNumber(string: newtext)
            self.lineItem?.quantity = self.quantity
        }
        return (numMatches == 1)
    }
}

extension InventoryQuantityTableViewCell: DoneEditingInputAccessoryDelegate {
    
    func doneEditingInputAccessoryDoneButtonTapped(inputAccessory: DoneEditingInputAccessoryView) {
        self.inventoryQuantityField.resignFirstResponder()
    }
    
}

