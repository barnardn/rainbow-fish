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
        self.stepper.addTarget(self, action: #selector(InventoryQuantityTableViewCell.stepperValueDidChange(_:)), forControlEvents: .TouchUpInside)
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
        
        let nsText: NSString = textField.text!
        
        let existingDecimalRange = nsText.rangeOfString(".")
        if existingDecimalRange.location != NSNotFound && string == "." {
            return false
        }
        let valueString = nsText.stringByReplacingCharactersInRange(range, withString: string) as String
        
        if valueString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            self.quantity = NSDecimalNumber(int: 0)
            return true
        }
        
        let regex = (try? NSRegularExpression(pattern: "^(\\d*)\\.?\\d*", options: NSRegularExpressionOptions())) as NSRegularExpression!
        
        if let matchResult = regex.firstMatchInString(valueString, options: NSMatchingOptions(), range: NSMakeRange(0, valueString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))) {
            let matchRange = matchResult.rangeAtIndex(0)
            let nsStr = valueString as NSString
            let matchString = nsStr.substringWithRange(matchRange)
            self.quantity = NSDecimalNumber(string: matchString)
            self.lineItem?.quantity = self.quantity
            return true
        }
        return false
    }
}

extension InventoryQuantityTableViewCell: DoneEditingInputAccessoryDelegate {
    
    func doneEditingInputAccessoryDoneButtonTapped(inputAccessory: DoneEditingInputAccessoryView) {
        self.inventoryQuantityField.resignFirstResponder()
    }
    
}

