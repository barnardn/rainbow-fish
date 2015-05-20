//
//  SettingsNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/14/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class SettingsNavigationController: UINavigationController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init() {
        self.init()
        self.viewControllers = [SettingsTableViewController()]
    }

}
