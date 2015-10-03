//
//  Array+CDOExtensions.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/21/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation

extension Array {
    
    func insertionIndexOf(item: Element, isOrderedBefore: (Element,Element) -> Bool) -> Int {
        if self.count == 0 {
            return 0
        } else if self.count == 1 {
            return isOrderedBefore(item, self[0]) ? 0 : 1
        }
        var lo = 0, hi = self.count, mid = self.count / 2
        while (lo <= hi) {
            if isOrderedBefore(item, self[mid]) {
                hi = mid - 1
            } else if isOrderedBefore(self[mid], item) {
                lo = mid + 1
            } else {
                return mid
            }
            mid = (lo + hi)/2
        }
        return lo
    }
    
}