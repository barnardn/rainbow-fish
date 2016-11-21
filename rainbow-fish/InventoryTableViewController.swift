//
//  InventoryTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CoreData
import CoreDataKit
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class InventoryTableViewController: ContentTableViewController {

    private static var __once: () = { () -> Void in
            AppController.appController.appConfiguration.addObserver(self, forKeyPath: "minInventoryQuantity", options: .new, context: &InventoryTableViewController.inventoryKVOContext)
        }()

    enum InventorySortModes: Int {
        case alpha = 0, quantity
    }

    fileprivate var inventoryKVOContext = 0
    
    var inventory = [Inventory]()
    
    lazy var sortMethodSegmentedControl: UISegmentedControl = {
        
        let segControl =  UISegmentedControl(items: [
            NSLocalizedString("A-Z",  comment: "inventory sort alpha title"),
            NSLocalizedString("Least - Most", comment: "inventory tab sort lest to most title")])
        
        segControl.selectedSegmentIndex = InventorySortModes.alpha.rawValue
        segControl.tintColor = UIColor.white
        segControl.addTarget(self, action: #selector(InventoryTableViewController.segmentControlChanged(_:)), for: .valueChanged)
        return segControl
    }()
    
    lazy var searchResultsTableController: InventorySearchResultsTableViewController = {
        let controller =  InventorySearchResultsTableViewController()
        controller.tableView.delegate = self
        return controller
    }()
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: self.searchResultsTableController)
        controller.searchResultsUpdater = self
        controller.searchBar.sizeToFit()
        controller.delegate = self
        controller.searchBar.delegate = self
        return controller
    }()

    convenience init() {
        self.init(style: UITableViewStyle.plain)
        let image = UIImage(named:"tabbar-icon-inventory")?.withRenderingMode(.alwaysTemplate)
        let title = NSLocalizedString("My Pencils", comment: "my pencils tab bar item title")
        self.tabBarItem = UITabBarItem(title: title, image: image, tag: 0)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = sortMethodSegmentedControl
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.register(UINib(nibName: InventoryTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: InventoryTableViewCell.nibName)
        self.tableView.tableHeaderView = self.searchController.searchBar
        NotificationCenter.default.addObserver(self, selector: #selector(InventoryTableViewController.didEditPencil(_:)), name: NSNotification.Name(rawValue: AppNotifications.DidEditPencil.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InventoryTableViewController.didFinishUpdatingCatalog(_:)), name: NSNotification.Name(rawValue: AppNotifications.DidFinishCloudUpdate.rawValue), object: nil)
        self.updateInventory()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // because the app settings are lazy loaded must observe them after we've updated our badge count to avoid triggering kvo!
        // may need to revisit this in the future
        struct Static {
            static var token: Int = 0
        }
        _ = InventoryTableViewController.__once
        
        if self.inventory.count == 0 {
            AppController.appController.setAppIconBadgeNumber(badgeNumber: 0)
        }
        
    }


    func segmentControlChanged(_ sender: UISegmentedControl) {
        self.updateInventory()
    }
    
    func updateInventory() {
        var sortDescriptors = [NSSortDescriptor]()
        sortDescriptors.append(NSSortDescriptor(key: InventoryAttributes.name.rawValue, ascending: true))
        if self.sortMethodSegmentedControl.selectedSegmentIndex == InventorySortModes.quantity.rawValue {
            sortDescriptors = [NSSortDescriptor(key: InventoryAttributes.quantity.rawValue, ascending: true)]
        }
        let results = Inventory.fullInventory(inContext: CDK.mainThreadContext, sortedBy: sortDescriptors)
        self.inventory = results ?? [Inventory]()
        self.updateBadgeCount(reloadingVisibleRows: false)
        self.tableView.reloadData()
    }
    
    func sortCurrentInventoryByQuantity() {
        let sorted = self.inventory.sorted { (item1: Inventory, item2: Inventory) -> Bool in
            if item1.quantity?.doubleValue == item2.quantity?.doubleValue {
                return item1.name < item2.name
            }
            return item1.quantity?.doubleValue < item2.quantity?.doubleValue
        }
        self.inventory = sorted
    }
    
    // MARK: NSNotification handler
    
    func didEditPencil(_ notification: Notification) {
        self.updateInventory()
    }
    
    func didFinishUpdatingCatalog(_ notification: Notification) {
        
        if (!AppController.appController.didDisplayInventoryHint) {
            HintView.show(title: NSLocalizedString("New User Tip", comment:"hint title"), hint: NSLocalizedString("Add pencils to your \"My Pencils\" inventory by selecting a pencil from the \"Catalog\", then tap the \"Add Pencil to My Inventory\" button.", comment:"invenory hint"))
            AppController.appController.didDisplayInventoryHint = true
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AppNotifications.DidFinishCloudUpdate.rawValue), object: nil)
        }
    }
    
    
    // MARK: kvo 

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context != &inventoryKVOContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        self.updateBadgeCount(reloadingVisibleRows: true)
    }
    
    fileprivate func updateBadgeCount(reloadingVisibleRows: Bool) {
        
        let minimumQuantity = AppController.appController.appConfiguration.minInventoryQuantity
        if minimumQuantity == nil {
            return
        }
        let lowStock = self.inventory.filter{ (lineItem: Inventory) -> Bool in
            if let qty = lineItem.quantity {
                let result = minimumQuantity!.compare(qty)
                return (result != .orderedAscending)
            } else {
                return true
            }
        }
        self.tabBarItem.badgeValue = nil
        AppController.appController.setAppIconBadgeNumber(badgeNumber: 0)
        if lowStock.count > 0 {
            self.tabBarItem.badgeValue = "\(lowStock.count)"
            AppController.appController.setAppIconBadgeNumber(badgeNumber: lowStock.count)
        }
        if !reloadingVisibleRows {
            return
        }
        if let indexPaths = self.tableView.indexPathsForVisibleRows {
            self.tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    // MARK: tableview datasource
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inventory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InventoryTableViewCell.nibName, for: indexPath) as! InventoryTableViewCell
        let lineItem = self.inventory[indexPath.row]
        cell.title = lineItem.name
        if let qty = lineItem.quantity {
            cell.quantity = qty.stringValue
        }
        if let productName = lineItem.productName {
            if let pencilIdent = lineItem.pencilIdentifier {
                cell.subtitle = "\(productName) \(pencilIdent)"
            }
        }
        cell.swatchColor = lineItem.color as? UIColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (tableView == self.tableView)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // exists solely to allow editting
    }
    
    // MARK: tableview delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var datasource = self.inventory
        if tableView == self.searchResultsTableController.tableView {
            datasource = self.searchResultsTableController.searchResults
        }
        let lineItem = datasource[indexPath.row]
        let viewController = InventoryDetailTableViewController(lineItem: lineItem)
        
        if self.presentedViewController == self.searchController {
            self.dismiss(animated: true) {
                self.searchController.searchBar.text = nil
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        viewController.itemUpdatedBlock = { [unowned self] (itemID : NSManagedObjectID, wasDeleted: Bool) in
            if wasDeleted {
                if tableView == self.searchResultsTableController.tableView {
                    let inventoryIndex = self.findIndexOfItemByManagedObjectID(itemID)
                    if inventoryIndex != NSNotFound {
                        self.inventory.remove(at: inventoryIndex)
                    }
                    self.tableView.reloadData()
                    self.searchResultsTableController.searchResults.remove(at: indexPath.row)
                } else {
                    self.inventory.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                if tableView == self.searchResultsTableController.tableView {
                    self.tableView.reloadData()
                } else if self.sortMethodSegmentedControl.selectedSegmentIndex == InventorySortModes.quantity.rawValue {
                    self.sortCurrentInventoryByQuantity()
                    tableView.reloadData()
                } else {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }

            }
            self.updateBadgeCount(reloadingVisibleRows: false)
        }
    }

    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView != self.tableView {
            return nil
        }
        let addAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: NSLocalizedString("+", comment:"inventory add pencil table action ")) { [unowned self] (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            let lineItem = self.inventory[indexPath.row]
            self.quantityUpdateAction(lineItem: lineItem, atIndexPath: indexPath, addition: true)
        }
        addAction.backgroundColor = AppearanceManager.appearanceManager.brandColor
        
        let subtractAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("- ", comment:"subtract pencil")) { [unowned self] (action, indexPath) -> Void in
            let lineItem = self.inventory[indexPath.row]
            self.quantityUpdateAction(lineItem: lineItem, atIndexPath: indexPath, addition: false)
        }
        subtractAction.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
        
        let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment:"delete action title")) { (_, indexPath) -> Void in
            let lineItem = self.inventory[indexPath.row]
            self.deleteLineItemAction(lineItem: lineItem, atIndexPath: indexPath)
        }
        
        return [deleteAction, addAction, subtractAction]
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0;
    }
    
    //MARK: private api
    
    fileprivate func quantityUpdateAction(lineItem: Inventory, atIndexPath indexPath: IndexPath, addition: Bool) {

        let context = lineItem.managedObjectContext!

        context.perform({ [unowned self]() -> Void in

            if let qty = lineItem.quantity {
                if addition {
                    lineItem.quantity = qty.adding(NSDecimalNumber.one)
                } else {
                    let x = qty.subtracting(NSDecimalNumber.one) as NSDecimalNumber
                    if x.doubleValue < 0 {
                        lineItem.quantity = NSDecimalNumber.zero
                    } else {
                        lineItem.quantity = x
                    }
                }
            } else {
                if addition {
                    lineItem.quantity = NSDecimalNumber.one
                }
            }
            do {
                try context.save()
            } catch _ {
            }
            do {
                try context.parent?.save()
            } catch _ {
            }

            let cell = self.tableView.cellForRow(at: indexPath) as! InventoryTableViewCell
            cell.quantity = lineItem.quantity?.stringValue
            self.updateBadgeCount(reloadingVisibleRows: false)
        })

    }
    
    fileprivate func deleteLineItemAction(lineItem: Inventory, atIndexPath indexPath: IndexPath) {
        
        self.inventory.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        CDK.performOnBackgroundContext(block: { (ctxt: NSManagedObjectContext) in
            
            let item = ctxt.object(with: lineItem.objectID)
            ctxt.delete(item)
            return CommitAction.saveToPersistentStore
            
            }, completionHandler: { [unowned self] (result) in
                do {
                    let _ = try result()
                    DispatchQueue.main.async {[unowned self] in
                        self.updateBadgeCount(reloadingVisibleRows: false)
                    }
                } catch {
                    assertionFailure()
                }
            })
    }
    
    func findIndexOfItemByManagedObjectID( _ managedObjectID: NSManagedObjectID) -> Int {
        if self.inventory.count == 0 {
            return NSNotFound
        }
        for i in 0 ..< self.inventory.count {
            let item = self.inventory[i]
            if managedObjectID == item.objectID {
                return i
            }
        }
        return NSNotFound
    }
    
}

extension InventoryTableViewController : UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as! InventorySearchResultsTableViewController
        
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        var subpredicates = [NSPredicate]()
        for searchText in searchItems {
            let namePredicate = NSPredicate(format: "name contains[cd] %@ ", searchText)
            let manufacturerPredicate = NSPredicate(format: "%K contains[cd] %@", InventoryAttributes.manufacturerName.rawValue, searchText)
            let productPredicate = NSPredicate(format: "%K contains[cd] %@", InventoryAttributes.productName.rawValue, searchText)
            let identifierPredicate = NSPredicate(format: "%K contains[cd] %@", InventoryAttributes.pencilIdentifier.rawValue, searchText)
            let subpredicate = NSCompoundPredicate(type: .or, subpredicates: [namePredicate, identifierPredicate, manufacturerPredicate, productPredicate])
            subpredicates.append(subpredicate)
        }
        let searchPredicate = NSCompoundPredicate(type: .or, subpredicates: subpredicates)
        
        let results = self.inventory.filter{ searchPredicate.evaluate(with: $0) }
        
        resultsController.searchResults = results 
        resultsController.tableView.reloadData()
    }

    
}


