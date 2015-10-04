//
//  PencilColorPickerTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/10/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit


protocol PencilColorPickerTableViewCellDelegate {
    func colorPickerTableViewCell(cell: PencilColorPickerTableViewCell, didChangeColor color: UIColor)
    func colorPickerTableViewCell(cell: PencilColorPickerTableViewCell, didRequestHexCodeWithColor color: UIColor?)
}


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
    @IBOutlet weak var hexEntryButton: UIButton!
    
    var color: UIColor?
    
    var defaultColor: UIColor? {
        willSet(inValue) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            if let color = inValue {
                (red, green, blue, _) = color.getCGFloatValues()
                hexValueLabel.text = color.hexRepresentation
                swatchView.backgroundColor = color
            }
            redSlider.CGFloatValue = red
            greenSlider.CGFloatValue = green
            blueSlider.CGFloatValue = blue
            redValueLabel.text = "\(Int(red * 255.0))"
            greenValueLabel.text = "\(Int(green * 255.0))"
            blueValueLabel.text = "\(Int(blue * 255.0))"
        }
    }
    
    var delegate: PencilColorPickerTableViewCellDelegate?
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
        hexEntryButton.addTarget(self, action: Selector("hexEntryButtonTapped:"), forControlEvents: .TouchUpInside)
        hexEntryButton.setTitleColor(AppearanceManager.appearanceManager.brandColor, forState: .Normal)
        sliders = [redSlider, greenSlider, blueSlider]
        
        self.selectionStyle = .None
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        self.redLabel.text = NSLocalizedString("R:", comment:"red 'R' label")
        self.greenLabel.text = NSLocalizedString("G:", comment:"green 'G' label")
        self.blueLabel.text = NSLocalizedString("B:", comment:"blue 'B' label")
        
        swatchView.backgroundColor = UIColor.blackColor()
        swatchView.layer.borderColor = UIColor.blackColor().CGColor
        swatchView.layer.borderWidth = CGFloat(1.0)
    }

    func sliderValueChanged(slider: UISlider) {
        let value = Int(slider.value * 255.0)
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
        self.hexValueLabel.text = color.hexRepresentation
        self.color = color
        if let delegate = self.delegate {
            delegate.colorPickerTableViewCell(self, didChangeColor: color)
        }
    }
    
    func hexEntryButtonTapped(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.colorPickerTableViewCell(self, didRequestHexCodeWithColor: self.color)
        }
    }
    
    class var nibName: String {
        return "PencilColorPickerTableViewCell"
    }
    
    class var preferredRowHeight: CGFloat {
        return 200.0
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


