//
//  SettingsMinimumStockTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/15/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CoreData
import CoreDataKit
import UIKit

class SettingsMinimumStockTableViewController: UITableViewController {

    var values = [NSDecimalNumber]()
    let halfSymbol = "½"
    
    convenience init() {
        self.init(style: .Grouped)
        self.title = NSLocalizedString("Minimum Inventory", comment:"settings minimum inventory view title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = false
        self.tableView.registerNib(UINib(nibName: DefaultTableViewCell.nibName as String, bundle: nil), forCellReuseIdentifier: DefaultTableViewCell.nibName as String)
        
        let wholeNumbers = [0,0,1,1,2,2,3]
        for var i = 0; i < wholeNumbers.count; i++ {
            var value = NSDecimalNumber(integer: wholeNumbers[i])
            if i % 2 > 0 {
                value = value.decimalNumberByAdding(NSDecimalNumber(floatLiteral: 0.5))
            }
            self.values.append(value)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let context = AppController.appController.appConfiguration.managedObjectContext {
            if !context.hasChanges {
                return
            }
            context.performBlock({(_) in
                return .SaveToPersistentStore
            }, completionHandler: {(result: Result<CommitAction>) in
                if let error = result.error() as NSError? {
                    assertionFailure(error.localizedDescription)
                }
            })
        }
    }

}

extension SettingsMinimumStockTableViewController: UITableViewDataSource {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.values.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DefaultTableViewCell.nibName as String, forIndexPath: indexPath) as! DefaultTableViewCell
        cell.tintColor = AppearanceManager.appearanceManager.brandColor
        cell.selectionStyle = .None
        let value = self.values[indexPath.row]
        switch indexPath.row {
        case 1:
            cell.textLabel?.text = self.halfSymbol
        case 0, 2, 4, 6:
            cell.textLabel?.text = value.stringValue
        default:
            let wholeValue = self.values[indexPath.row-1]
            cell.textLabel?.text = wholeValue.stringValue + self.halfSymbol
        }
        return cell
    }
    
}

extension SettingsMinimumStockTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let value = self.values[indexPath.row]
        if let minInventory = AppController.appController.appConfiguration.minInventoryQuantity {
            if value.compare(minInventory) == .OrderedSame {
                cell.accessoryType = .Checkmark
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
        } else {
            cell.accessoryType = .None
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        AppController.appController.appConfiguration.minInventoryQuantity = self.values[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .None
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("This number represents the fewest number of pencils you have on-hand before you need to replenish your stock.", comment:"settings minimum stock instructions")
    }
    
    
}