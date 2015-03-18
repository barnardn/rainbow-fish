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

class InventoryTableViewController: ContentTableViewController {

    enum InventorySortModes: Int {
        case Alpha = 0, Quantity
    }

    private var inventoryKVOContext = 0
    
    var inventory = [Inventory]()
    
    lazy var sortMethodSegmentedControl: UISegmentedControl = {
        
        let segControl =  UISegmentedControl(items: [
            NSLocalizedString("A-Z",  comment: "inventory sort alpha title"),
            NSLocalizedString("Least - Most", comment: "inventory tab sort lest to most title")])
        
        segControl.selectedSegmentIndex = InventorySortModes.Alpha.rawValue
        segControl.tintColor = UIColor.whiteColor()
        segControl.addTarget(self, action: Selector("segmentControlChanged:"), forControlEvents: .ValueChanged)
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
        self.init(style: UITableViewStyle.Plain)
        var image = UIImage(named:"tabbar-icon-inventory")?.imageWithRenderingMode(.AlwaysTemplate)
        let title = NSLocalizedString("My Pencils", comment: "my pencils tab bar item title")
        self.tabBarItem = UITabBarItem(title: title, image: image, tag: 0)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = sortMethodSegmentedControl
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.registerNib(UINib(nibName: InventoryTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: InventoryTableViewCell.nibName)
        self.tableView.tableHeaderView = self.searchController.searchBar
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didEditPencil:"), name: AppNotifications.DidEditPencil.rawValue, object: nil)
        
        definesPresentationContext = true
        self.updateInventory()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // because the app settings are lazy loaded must observe them after we've updated our badge count to avoid triggering kvo!
        // may need to revisit this in the future
        struct Static {
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token, { () -> Void in
            AppController.appController.appConfiguration.addObserver(self, forKeyPath: "minInventoryQuantity", options: .New, context: &self.inventoryKVOContext)
        })
    }


    func segmentControlChanged(sender: UISegmentedControl) {
        self.updateInventory()
    }
    
    func updateInventory() {
        var sortDescriptors = [NSSortDescriptor]()
        sortDescriptors.append(NSSortDescriptor(key: InventoryAttributes.name.rawValue, ascending: true))
        if self.sortMethodSegmentedControl.selectedSegmentIndex == InventorySortModes.Quantity.rawValue {
            sortDescriptors = [NSSortDescriptor(key: InventoryAttributes.quantity.rawValue, ascending: true)]
        }
        let results = Inventory.fullInventory(inContext: CoreDataKit.mainThreadContext, sortedBy: sortDescriptors)
        self.inventory = results ?? [Inventory]()
        self.updateBadgeCount(reloadingVisibleRows: false)
        self.tableView.reloadData()
    }
    
    // MARK: NSNotification handler
    
    func didEditPencil(notification: NSNotification) {
        self.updateInventory()
    }
    
    // MARK: kvo 

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &inventoryKVOContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        self.updateBadgeCount(reloadingVisibleRows: true)
    }
    
    private func updateBadgeCount(#reloadingVisibleRows: Bool) {
        
        let minimumQuantity = AppController.appController.appConfiguration.minInventoryQuantity
        if minimumQuantity == nil {
            return
        }
        let lowStock = self.inventory.filter{ (lineItem: Inventory) -> Bool in
            if let qty = lineItem.quantity {
                let result = minimumQuantity!.compare(qty)
                return (result != .OrderedAscending)
            } else {
                return true
            }
        }
        self.tabBarItem.badgeValue = nil
        if lowStock.count > 0 {
            self.tabBarItem.badgeValue = "\(lowStock.count)"
        }
        if !reloadingVisibleRows {
            return
        }
        if let indexPaths = self.tableView.indexPathsForVisibleRows() {
            self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        }
    }
    
}

extension InventoryTableViewController : UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inventory.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(InventoryTableViewCell.nibName, forIndexPath: indexPath) as InventoryTableViewCell
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
}

extension InventoryTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var datasource = self.inventory
        if tableView == self.searchResultsTableController.tableView {
            datasource = self.searchResultsTableController.searchResults
        }
        let lineItem = datasource[indexPath.row]
        let viewController = InventoryDetailTableViewController(lineItem: lineItem)
        self.navigationController?.pushViewController(viewController, animated: true)
        
        viewController.itemUpdatedBlock = { [unowned self] (itemID : NSManagedObjectID, wasDeleted: Bool) in
            if wasDeleted {
                if tableView == self.searchResultsTableController.tableView {
                    let inventoryIndex = self.findIndexOfItemByManagedObjectID(itemID)
                    if inventoryIndex != NSNotFound {
                        self.inventory.removeAtIndex(inventoryIndex)
                    }
                    self.tableView.reloadData()
                    self.searchResultsTableController.searchResults.removeAtIndex(indexPath.row)
                } else {
                    self.inventory.removeAtIndex(indexPath.row)
                }
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            } else {
                if tableView == self.searchResultsTableController.tableView {
                    self.tableView.reloadData()
                }
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            self.updateBadgeCount(reloadingVisibleRows: false)
        }
    }
    
    func findIndexOfItemByManagedObjectID( managedObjectID: NSManagedObjectID) -> Int {
        if self.inventory.count == 0 {
            return NSNotFound
        }
        for var i = 0; i < self.inventory.count; i++ {
            let item = self.inventory[i]
            if managedObjectID == item.objectID {
                return i
            }
        }
        return NSNotFound
    }
    
}

extension InventoryTableViewController : UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as InventorySearchResultsTableViewController
        
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        var subpredicates = [NSPredicate]()
        for searchText in searchItems {
            let namePredicate = NSPredicate(format: "name contains[cd] %@ ", searchText)
            let manufacturerPredicate = NSPredicate(format: "%K contains[cd] %@", InventoryAttributes.manufacturerName.rawValue, searchText)
            let productPredicate = NSPredicate(format: "%K contains[cd] %@", InventoryAttributes.productName.rawValue, searchText)
            let identifierPredicate = NSPredicate(format: "%K contains[cd] %@", InventoryAttributes.pencilIdentifier.rawValue, searchText)
            let subpredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: [namePredicate!, identifierPredicate!, manufacturerPredicate!, productPredicate!])
            subpredicates.append(subpredicate)
        }
        let searchPredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: subpredicates)
        
        let results = self.inventory.filter{ searchPredicate.evaluateWithObject($0) }
        
        resultsController.searchResults = results ?? [Inventory]()
        resultsController.tableView.reloadData()
    }

    
}


