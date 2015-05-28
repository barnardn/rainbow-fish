//
//  PencilNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class CatalogNavigationController: UINavigationController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        var image = UIImage(named: "tabbar-icon-pencils")?.imageWithRenderingMode(.AlwaysTemplate)
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("Catalog", comment:"all pencils tab bar item title"), image: image, tag: 1)
        self.title = NSLocalizedString("Catalog", comment:"browse all pencils navigation title")        
        self.viewControllers = [CatalogViewController()]
    }
}
