//
//  EditProductNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/21/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class EditProductNavigationController: UINavigationController {
   
    convenience init(product: Product?, completion: @escaping EditTextFieldTableViewCompletionBlock) {
        self.init(nibName: nil, bundle: nil)
        var viewController: EditTextFieldTableViewController!
        if let p = product {
            viewController = EditTextFieldTableViewController(title: NSLocalizedString("Edit Product", comment:"edit product title"), defaultText: p.name, placeholder: NSLocalizedString("Product Name", comment:"edit product placeholder"), completion: completion)
        } else {
            viewController = EditTextFieldTableViewController(title: NSLocalizedString("New Product", comment:"add product title"), defaultText: String(), placeholder: NSLocalizedString("Product Name", comment:"edit product placeholder"), completion: completion)
        }
        self.viewControllers = [viewController]
    }
    
}
