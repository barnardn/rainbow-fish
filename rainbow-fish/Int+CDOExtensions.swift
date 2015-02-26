//
//  Int+CDOExtensions.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/22/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.

import Foundation

extension Int {
    
    // return an hex representation of an Int
    func toHex() -> String {
        var string: String = NSString(format: "%02X", self)
        return string
    }
    
}