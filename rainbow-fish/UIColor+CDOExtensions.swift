//
//  UIColor+CDOExtensions.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/22/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    func getIntegerValues() -> (r: Int, g: Int, b: Int, alpha: Float) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Int(red * 256.0), Int(green * 256.0), Int(blue * 256.0), Float(alpha))
    }
    
    func getCGFloatValues() -> (r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
        var values = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getRed(&values[0], green: &values[1], blue: &values[2], alpha: &values[3])
        return (values[0], values[1], values[2], values[3])
    }
    
    var hexRepresentation: String {
        get {
            let (r,g,b,_) = self.getIntegerValues()
            return "#\(r.toHex())\(g.toHex())\(b.toHex())"
        }
    }
    
    var rgbRepresentation: String {
        get {
            let (r,g,b,_) = self.getIntegerValues()
            return "\(r),\(g),\(b)"
        }
    }
    
    class func colorFromRGBString(rgbString: String?) -> UIColor {
        if let rgbString = rgbString {
            if rgbString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 5 {
                return UIColor.blackColor()
            }
            let rgbParts = rgbString.componentsSeparatedByString(",")
            if rgbParts.count != 3 {
                return UIColor.blackColor()
            }
            let rgbValues = rgbParts.map{(str: String) in Float(Int(str)!)/256.0 }
            return UIColor(red: CGFloat(rgbValues[0]), green: CGFloat(rgbValues[1]), blue: CGFloat(rgbValues[2]), alpha: 1.0)
        }
        return UIColor.blackColor()
    }
    
    class func colorFromHexString(hexString: String) -> UIColor? {
        var str = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString as String
        while str.hasPrefix("#") {
            str = str.substringFromIndex(str.startIndex.advancedBy(1))
        }
        while str.hasPrefix("0X") {
            str = str.substringFromIndex(str.startIndex.advancedBy(2))
        }
        if str.characters.count != 6 {
            return nil
        }
        var rgbValue : UInt32 = 0
        NSScanner(string: str).scanHexInt(&rgbValue)
        
        return UIColor(red: CGFloat((rgbValue & 0xFF0000)>>16) / 255.0, green: CGFloat((rgbValue & 0x00FF00)>>8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
    
}