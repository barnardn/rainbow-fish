//
//  InventoryTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class InventoryTableViewController: ContentTableViewController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Plain)
        var image = UIImage(named:"tabbar-icon-inventory")?.imageWithRenderingMode(.AlwaysTemplate)
        self.tabBarItem = UITabBarItem(title: "Inventory", image: image, tag: 0)
    }

    
    
}
