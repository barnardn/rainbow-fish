//
//  GCDHelpers.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/6/16.
//  Copyright © 2016 Clamdango. All rights reserved.
//

import Foundation


func delay(delay: Double, block:() -> Void) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue(), block)
}