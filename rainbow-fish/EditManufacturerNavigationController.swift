//
//  EditManufacturerNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/21/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class EditManufacturerNavigationController: UINavigationController {
   
    convenience init(manufacturer: Manufacturer?, completion: @escaping EditTextFieldTableViewCompletionBlock) {
        self.init(nibName: nil, bundle: nil)
        var viewController: EditTextFieldTableViewController!
        if let m = manufacturer {
            viewController = EditTextFieldTableViewController(title: NSLocalizedString("Edit Manufacturer", comment:"edit manufacturer title"), defaultText: m.name, placeholder: NSLocalizedString("Manufacturer Name", comment:"edit manufacturer placeholder"), completion: completion)
        } else {
            viewController = EditTextFieldTableViewController(title: NSLocalizedString("New Manufacturer", comment:"add manufacturer title"), defaultText: String(), placeholder: NSLocalizedString("Manufacturer Name", comment:"edit manufacturer placeholder"), completion: completion)
        }
        self.viewControllers = [viewController]
    }
    
}
