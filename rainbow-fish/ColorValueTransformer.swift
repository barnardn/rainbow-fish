//
//  ColorValueTransformer.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class ColorValueTransformer: NSValueTransformer {

    
    class func allowsReveseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return UIColor.self
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        
        if let stringValue = value as String? {
            let rgb = stringValue.componentsSeparatedByString(",")
            assert(rgb.count == 3, "string returned was not a triple: \(stringValue)")
            var red = rgb[0].toInt() ?? 0
            var green = rgb[1].toInt() ?? 0
            var blue = rgb[2].toInt() ?? 0
            return UIColor(red: CGFloat(Float(red)/256.0), green: CGFloat(Float(green)/256.0), blue: CGFloat(Float(blue)/256.0), alpha: 1.0)
        }
        return UIColor.blackColor()
    }

    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        
        if let colorValue = value as UIColor? {
            var red, green, blue, alpha: CGFloat
            red = 0.0
            green = 0.0
            blue = 0.0
            alpha = 0.0
            let ok = colorValue.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            if ok {
                return "\(Int(red * 256.0)),\(Int(green * 256.0)),\(Int(blue * 256.0))"
            }
        }
        return String()
    }
}
