//
//  SettingsTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CoreData
import CoreDataKit
import UIKit

class SettingsTableViewController: ContentTableViewController {

    enum Sections: Int {
        case MinimumInventory
    }
    
    private var settingsContext = 0
    
    let sectionInfo = [ [Sections.MinimumInventory] ]
    
    convenience init() {
        self.init(style: .Grouped)
        let image = UIImage(named: "tabbar-icon-settings")?.imageWithRenderingMode(.AlwaysTemplate)
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment:"setting tabbar item title"), image: image, tag: 0)
        self.title = NSLocalizedString("Settings", comment:"setting tabbar item title")
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "minInventoryQuantity", context: &settingsContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        AppController.appController.appConfiguration.addObserver(self, forKeyPath: "minInventoryQuantity", options: .New, context: &settingsContext)
    }
    
    // MARK: kvo 
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &settingsContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        if keyPath == "minInventoryQuantity" {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: Sections.MinimumInventory.rawValue)], withRowAnimation: .None)
        }
    }
    
    
}


extension SettingsTableViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionInfo.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let thisSection = self.sectionInfo[section]
        return thisSection.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NameValueTableViewCell.nibName, forIndexPath: indexPath) as NameValueTableViewCell
        cell.name = NSLocalizedString("Minimum Inventory", comment:"settings pencil remaining title")
        if let quantity = AppController.appController.appConfiguration.minInventoryQuantity {
            cell.value = formatDecimalQuantity(quantity)
        } else {
            cell.value = "0"
        }
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    private func formatDecimalQuantity(quantity: NSDecimalNumber) -> String {
        let wholeNumber = Int(floorf(quantity.floatValue))
        if fmodf(quantity.floatValue, 1.0) > 0 {
            if wholeNumber == 0 {
                return "½"
            } else {
                return "\(wholeNumber)½"
            }
        }
        return "\(wholeNumber)"
    }


}

extension SettingsTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController: UIViewController
        switch indexPath.section {
        default:
            viewController = SettingsMinimumStockTableViewController()
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

