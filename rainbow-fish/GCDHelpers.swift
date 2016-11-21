//
//  GCDHelpers.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/6/16.
//  Copyright © 2016 Clamdango. All rights reserved.
//

import Foundation


func delay(_ delay: Double, block:@escaping () -> Void) {
    let delayTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime, execute: block)
}
