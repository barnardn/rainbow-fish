//
//  PencilColorPickerTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/10/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilColorPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var redValueLabel: UILabel!
    @IBOutlet weak var greenValueLabel: UILabel!
    @IBOutlet weak var blueValueLabel: UILabel!
    @IBOutlet weak var hexValueLabel: UILabel!
    @IBOutlet var colorValueLabel: [UILabel]!
    @IBOutlet weak var swatchView: UIView!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    
    var color: UIColor?
    
    var defaultColor: UIColor? {
        willSet(inValue) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            if let color = inValue {
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            }
            redSlider.CGFloatValue = red
            greenSlider.CGFloatValue = green
            blueSlider.CGFloatValue = blue
        }
    }
    var sliders: [UISlider]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for label in colorValueLabel {
            label.font = AppearanceManager.appearanceManager.subtitleFont
            label.textColor = AppearanceManager.appearanceManager.bodyTextColor
            label.text = "0"
        }
        hexValueLabel.text = "#000000"
        redSlider.addTarget(self, action: Selector("sliderValueChanged:"), forControlEvents: .ValueChanged)
        greenSlider.addTarget(self, action: Selector("sliderValueChanged:"), forControlEvents: .ValueChanged)
        blueSlider.addTarget(self, action: Selector("sliderValueChanged:"), forControlEvents: .ValueChanged)
        sliders = [redSlider, greenSlider, blueSlider]
        
        self.selectionStyle = .None
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        self.redLabel.text = NSLocalizedString("R:", comment:"red 'R' label")
        self.greenLabel.text = NSLocalizedString("G:", comment:"green 'G' label")
        self.blueLabel.text = NSLocalizedString("B:", comment:"blue 'B' label")
        
        swatchView.backgroundColor = UIColor.whiteColor()
        swatchView.layer.borderColor = UIColor.blackColor().CGColor
        swatchView.layer.borderWidth = CGFloat(1.0)
    }

    func sliderValueChanged(slider: UISlider) {
        var value = Int(slider.value * 255.0)
        switch slider {
        case redSlider:
            redValueLabel.text = String(value)
        case greenSlider:
            greenValueLabel.text = String(value)
        case blueSlider:
            blueValueLabel.text = String(value)
        default:
            assertionFailure("Unknown event from object \(slider)")
        }
        let color = UIColor(red: redSlider.CGFloatValue, green: greenSlider.CGFloatValue, blue: blueSlider.CGFloatValue, alpha: 1.0)
        swatchView.backgroundColor = color
        updateHexString(color: color)
        self.color = color
    }
    
    func updateHexString(#color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.hexValueLabel.text = "#\(Int(red * 256.0).toHex())\(Int(green * 256.0).toHex())\(Int(blue * 256.0).toHex())"
    }
    
    class var nibName: String {
        return "PencilColorPickerTableViewCell"
    }
    
}

// convenience extension on UI Slider to work with values as CGFloats
extension UISlider {
    
    var CGFloatValue: CGFloat {
        get {
            return CGFloat(self.value)
        }
        set {
            self.value = Float(newValue)
        }
    }    
}


extension Int {

    // return an hex representation of an Int
    func toHex() -> String {
        var string: String = NSString(format: "%02X", self)
        return string
    }
    
}

