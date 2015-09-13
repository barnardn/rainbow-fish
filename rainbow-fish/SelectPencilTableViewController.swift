//
//  SelectPencilTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/8/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
import CoreData
import CoreDataKit

class SelectPencilTableViewController: ContentTableViewController {

    var product: Product!
    var pencils =  [Pencil]()
    
    lazy var searchResultsTableController: PencilSearchResultsTableViewController = {
        let controller =  PencilSearchResultsTableViewController()
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
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonTapped:"))
        return button
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Back", comment:"back button title"), style: .Plain, target: nil, action: nil)
        return button
    }()
    
    convenience init(product: Product) {
        self.init(style: UITableViewStyle.Plain)
        self.product = product
        self.title = NSLocalizedString(product.name!, comment:"select pencil view title")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.rowHeight = PencilTableViewCell.rowHeight
        self.tableView.registerNib(UINib(nibName: PencilTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilTableViewCell.nibName)
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = AppearanceManager.appearanceManager.brandColor
        self.refreshControl?.addTarget(self, action: Selector("refreshControlDidChange:"), forControlEvents: .ValueChanged)
        self.navigationItem.rightBarButtonItem = self.addButton
        self.navigationItem.backBarButtonItem = self.backButton
        definesPresentationContext = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("inventoryDidUpdate:"), name: AppNotifications.DidEditPencil.rawValue, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        updatePencils()
    }
    
    
    // MARK: action & event handlers
    
    func addButtonTapped(sender: UIBarButtonItem) {
        self.presentViewController(CreatePencilNavigationController(product: self.product), animated: true, completion: nil)
    }
    
    func refreshControlDidChange(sender: UIRefreshControl) {
        self.cloudUpdate(forced: true)
    }
    
    func inventoryDidUpdate(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let pencilObjectID = userInfo[AppNotificationInfoKeys.DidEditPencilPencilKey.rawValue] as? NSManagedObjectID {
            
                let pencil = self.product.managedObjectContext?.objectWithID(pencilObjectID) as! Pencil
                let row = self.pencils.insertionIndexOf(pencil, isOrderedBefore: { (p1: Pencil, p2: Pencil) -> Bool in
                    return p1.identifier == p2.identifier
                })
                if let visibleRows = self.tableView.indexPathsForVisibleRows() as! [NSIndexPath]? {
                    let results = visibleRows.filter{(indexPath: NSIndexPath) in
                        return indexPath.row == row
                    }
                    if results.count > 0 {
                        self.tableView.reloadRowsAtIndexPaths(results, withRowAnimation: .Automatic)
                    }
                }
            
        }
    }
    
    // MARK: private methods
    
    private func updatePencils() {
        if let pencils = Pencil.allPencils(forProduct: self.product, context: self.product.managedObjectContext!) {
            self.pencils = pencils
            tableView.reloadData()
        }
        self.cloudUpdate(forced: false)
    }
    
    private func cloudUpdate(#forced: Bool) {
        if !forced && !self.product.shouldPerformUpdate {
            return
        }
        if !forced {
            self.showSmallHUD(message: nil)
        }
        let modificationDate = recentModificationDate(inPencils: pencils)
        CloudManager.sharedManger.importAllPencilsForProduct(self.product, modifiedAfterDate: modificationDate ){ (success, error) in
            if !forced {
                self.hideSmallHUD()
            } else {
                self.refreshControl?.endRefreshing()
            }
            if error != nil {
                println(error?.localizedDescription)
            } else {
                self.pencils = Pencil.allPencils(forProduct: self.product, context: self.product.managedObjectContext!) ?? [Pencil]()
                self.tableView.reloadData()
            }
        }
    }
    
    private func recentModificationDate(inPencils pencils: [Pencil]) -> NSDate {
        if pencils.count == 0 {
            return NSDate(timeIntervalSinceReferenceDate: 0)
        }
        let newestPencil =  pencils.reduce(pencils.first!) { (p1: Pencil, p2: Pencil) -> Pencil in
            let date1 = p1.modificationDate ?? NSDate(timeIntervalSinceReferenceDate: 0)
            let date2 = p2.modificationDate ?? NSDate(timeIntervalSinceReferenceDate: 0)
            if date1.compare(date2) == NSComparisonResult.OrderedDescending {
                return p1
            }
            return p2
        }
        return newestPencil.modificationDate ?? NSDate()
    }

}

// MARK: UITableViewDataSource

extension SelectPencilTableViewController: UITableViewDataSource {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pencils.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PencilTableViewCell.nibName, forIndexPath: indexPath) as! PencilTableViewCell
        cell.accessoryType = .DisclosureIndicator
        let pencil = self.pencils[indexPath.row]
        cell.name = pencil.name
        cell.pencilIdentifier = pencil.identifier
        cell.colorSwatch = pencil.color as? UIColor
        cell.presentInInventory = (pencil.inventory != nil)
        return cell
    }
}

// MARK: UITableViewDelegate

extension SelectPencilTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var pencil: Pencil
        if tableView == searchResultsTableController.tableView {
            pencil = self.searchResultsTableController.searchResults[indexPath.row]
        } else {
            pencil = self.pencils[indexPath.row]
        }
        self.navigationController?.pushViewController(EditPencilTableViewController(pencil: pencil), animated: true)
    }
}

// MARK: search extensions

extension SelectPencilTableViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
 
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as! PencilSearchResultsTableViewController
        
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        var subpredicates = [NSPredicate]()
        for searchText in searchItems {
            let namePredicate = NSPredicate(format: "name contains[cd] %@ ", searchText)
            let identifierPredicate = NSPredicate(format: "identifier contains[cd] %@", searchText)
            let subpredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: [namePredicate, identifierPredicate])
            subpredicates.append(subpredicate)
        }
        let searchPredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: subpredicates)
        
        let results = self.pencils.filter{ searchPredicate.evaluateWithObject($0) }
        
        resultsController.searchResults = results ?? [Pencil]()
        resultsController.tableView.reloadData()
    }
    
}


