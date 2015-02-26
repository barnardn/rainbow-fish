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

class SelectPencilTableViewController: UITableViewController {

    var product: Product!
    var pencils: [Pencil]?
    
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
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.registerNib(UINib(nibName: DefaultDetailTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultDetailTableViewCell.nibName)
        self.navigationItem.rightBarButtonItem = self.addButton
        self.navigationItem.backBarButtonItem = self.backButton
        updatePencils()
        definesPresentationContext = true
    }
    
    func addButtonTapped(sender: UIBarButtonItem) {
        self.presentViewController(CreatePencilNavigationController(), animated: true, completion: nil)
    }
    
    private func updatePencils() {
        var modificationDate: NSDate?
        if let pencils = Pencil.allPencils(forProduct: self.product, context: self.product.managedObjectContext!) {
            self.pencils = pencils
            modificationDate = recentModificationDate(inPencils: pencils)
            tableView.reloadData()
        }
        self.showHUD(header: "Refreshing Pencils", footer: "Please Wait...")
        CloudManager.sharedManger.importPencilsForProduct(self.product, modifiedAfterDate: modificationDate ){ (success, error) in
            self.hideHUD()
            if error != nil {
                println(error?.localizedDescription)
            } else {
                self.pencils = Pencil.allPencils(forProduct: self.product, context: self.product.managedObjectContext!)
                self.tableView.reloadData()
            }
        }
    }
    
    private func recentModificationDate(inPencils pencils: [Pencil]) -> NSDate {
        let newestPencil =  pencils.reduce(pencils.first!) { (p1: Pencil, p2: Pencil) -> Pencil in
            let date1 = p1.modificationDate!
            let date2 = p2.modificationDate!
            if date1.compare(date2) == NSComparisonResult.OrderedDescending {
                return p1
            }
            return p2
        }
        return newestPencil.modificationDate!
    }

}

// MARK: UITableViewDataSource

extension SelectPencilTableViewController: UITableViewDataSource {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let pencils = self.pencils {
            return pencils.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DefaultDetailTableViewCell.nibName, forIndexPath: indexPath) as DefaultDetailTableViewCell
        cell.accessoryType = .DisclosureIndicator
        if let pencil = self.pencils?[indexPath.row] {
            cell.textLabel?.text = pencil.name
            cell.detailTextLabel?.text = pencil.identifier
        }
        return cell
    }
}

// MARK: UITableViewDelegate

extension SelectPencilTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let pencil = self.pencils?[indexPath.row] {
            self.navigationController?.pushViewController(EditPencilTableViewController(pencil: pencil), animated: true)
        }
    }
}

// MARK: search extensions

extension SelectPencilTableViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
 
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as PencilSearchResultsTableViewController
        
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        var subpredicates = [NSPredicate]()
        for searchText in searchItems {
            let namePredicate = NSPredicate(format: "name contains[cd] %@ ", searchText)
            let identifierPredicate = NSPredicate(format: "identifier contains[cd] %@", searchText)
            let subpredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: [namePredicate!, identifierPredicate!])
            subpredicates.append(subpredicate)
        }
        let searchPredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: subpredicates)
        
        let results = pencils?.filter{ searchPredicate.evaluateWithObject($0) }
        
        resultsController.searchResults = results ?? [Pencil]()
        resultsController.tableView.reloadData()
    }
    
}


