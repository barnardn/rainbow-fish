//
//  CreatePencilNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class CreatePencilNavigationController: UINavigationController {
       
    convenience init(product: Product) {
        self.init(nibName: nil, bundle: nil)
        self.viewControllers = [EditPencilTableViewController(product: product)]
    }
    
}
