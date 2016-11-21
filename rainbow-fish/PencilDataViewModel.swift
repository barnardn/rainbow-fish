//
//  PencilDataViewModel.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit

class PencilDataViewModel: NSObject {
    
    let childContext: NSManagedObjectContext
    dynamic var manufacturer: Manufacturer? {
        didSet {
            self.product = nil
        }
    }
    dynamic var product: Product?

    
    
    
    override init() {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, parentContext: CDK.mainThreadContext)
        super.init()
    }
    
}
