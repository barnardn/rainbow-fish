//
//  InventoryTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class InventoryTableViewController: ContentTableViewController {

    enum InventorySortModes: Int {
        case Alpha = 0, Quantity
    }
    
    var sortMethodSegmentedControl: UISegmentedControl?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Plain)
        var image = UIImage(named:"tabbar-icon-inventory")?.imageWithRenderingMode(.AlwaysTemplate)
        let title = NSLocalizedString("My Pencils", comment: "my pencils tab bar item title")
        self.tabBarItem = UITabBarItem(title: title, image: image, tag: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sortMethodSegmentedControl = UISegmentedControl(items: [
            NSLocalizedString("A-Z",  comment: "inventory sort alpha title"),
            NSLocalizedString("Least - Most", comment: "inventory tab sort lest to most title")])
        sortMethodSegmentedControl!.selectedSegmentIndex = InventorySortModes.Alpha.rawValue
        self.navigationItem.titleView = sortMethodSegmentedControl
        sortMethodSegmentedControl!.tintColor = AppearanceManager.appearanceManager.brandColorLight
    }
    
}
