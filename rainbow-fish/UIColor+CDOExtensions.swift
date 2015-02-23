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
    
    var hexRepresentation: String {
        get {
            let (r,g,b,alpha) = self.getIntegerValues()
            return "#\(r.toHex())\(g.toHex())\(b.toHex())"
        }
    }
    
}