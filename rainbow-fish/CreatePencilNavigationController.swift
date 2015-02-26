//
//  CreatePencilNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class CreatePencilNavigationController: UINavigationController {
   
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = [EditPencilTableViewController(pencil: nil)]
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
}
