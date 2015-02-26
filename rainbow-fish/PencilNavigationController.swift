//
//  PencilNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilNavigationController: UINavigationController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = [PencilViewController()]
    }
    
}
