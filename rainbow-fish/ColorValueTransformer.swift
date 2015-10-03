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
        if let colorValue = value as? UIColor {
            let (r,g,b,_) = colorValue.getIntegerValues()
            let str = "\(r),\(g),\(b)"
            return str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        return nil
    }

    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        if let dataValue = value as? NSData {
            let stringValue = NSString(data: dataValue, encoding: NSUTF8StringEncoding) as! String
            let rgb: [String] = stringValue.componentsSeparatedByString(",")
            assert(rgb.count == 3, "string returned was not a triple: \(stringValue)")
            let red = Int(rgb[0]) ?? 0
            let green = Int(rgb[1]) ?? 0
            let blue = Int(rgb[2]) ?? 0
            return UIColor(red: CGFloat(Float(red)/256.0), green: CGFloat(Float(green)/256.0), blue: CGFloat(Float(blue)/256.0), alpha: 1.0)
        }
        return nil
    }
}
