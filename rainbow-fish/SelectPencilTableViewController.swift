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
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SelectPencilTableViewController.addButtonTapped(_:)))
        return button
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Back", comment:"back button title"), style: .plain, target: nil, action: nil)
        return button
    }()
    
    convenience init(product: Product) {
        self.init(style: UITableViewStyle.plain)
        self.product = product
        self.title = NSLocalizedString(product.name!, comment:"select pencil view title")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.rowHeight = PencilTableViewCell.rowHeight
        self.tableView.register(UINib(nibName: PencilTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilTableViewCell.nibName)
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = AppearanceManager.appearanceManager.brandColor
        self.refreshControl?.addTarget(self, action: #selector(SelectPencilTableViewController.refreshControlDidChange(_:)), for: .valueChanged)
        
        self.navigationItem.backBarButtonItem = self.backButton
        NotificationCenter.default.addObserver(self, selector: #selector(SelectPencilTableViewController.inventoryDidUpdate(_:)), name: NSNotification.Name(rawValue: AppNotifications.DidEditPencil.rawValue), object: nil)

        // KVO on purchase status
        
        if !AppController.appController.appConfiguration.wasPurchasedSuccessfully {
            NotificationCenter.default.addObserver(self, selector: #selector(SelectPencilTableViewController.paymentUpdatedNotifcation(_:)), name: NSNotification.Name(rawValue: StoreKitPurchaseNotificationName), object: nil)
        }
        
        if AppController.appController.isNormsiPhone() && self.navigationItem.rightBarButtonItem == nil {
            self.navigationItem.rightBarButtonItem = self.addButton
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updatePencils()
    }
    
    
    // MARK: action & event handlers
    
    func addButtonTapped(_ sender: UIBarButtonItem) {
        self.present(CreatePencilNavigationController(product: self.product), animated: true, completion: nil)
    }
    
    func refreshControlDidChange(_ sender: UIRefreshControl) {
        self.cloudUpdate(forced: true)
    }
    
    func inventoryDidUpdate(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let pencilObjectID = userInfo[AppNotificationInfoKeys.DidEditPencilPencilKey.rawValue] as? NSManagedObjectID {
            
                let pencil = self.product.managedObjectContext?.object(with: pencilObjectID) as! Pencil
                let row = self.pencils.insertionIndexOf(pencil, isOrderedBefore: { (p1: Pencil, p2: Pencil) -> Bool in
                    return p1.identifier == p2.identifier
                })
                if let visibleRows = self.tableView.indexPathsForVisibleRows {
                    let results = visibleRows.filter{(indexPath: IndexPath) in
                        return indexPath.row == row
                    }
                    if results.count > 0 {
                        self.tableView.reloadRows(at: results, with: .automatic)
                    }
                }
            
        }
    }
    
    func paymentUpdatedNotifcation(_ notification: Notification) {
        if  let userInfo = notification.userInfo,
            let purchaseResult = userInfo[StoreKitPurchaseResultTypeKey] as! String? {
                if purchaseResult == StoreKitPurchaseResultType.Completed.rawValue {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: StoreKitPurchaseNotificationName), object: nil)
                }
        }
    }
    
    // MARK: private methods
    
    fileprivate func updatePencils() {
        
        if let pencils = try? Pencil.allPencils(forProduct: self.product, context: self.product.managedObjectContext!) {
            self.pencils = pencils ?? [Pencil]()
            tableView.reloadData()
        }
        if self.pencils.count == 0 {
            self.cloudUpdate(forced: false)
        }
    }
    
    fileprivate func cloudUpdate(forced: Bool) {
        if !forced {
            self.showSmallHUD(message: nil)
            self.tableView.isUserInteractionEnabled = false
        }
        let modificationDate = recentModificationDate(inPencils: pencils)
        CloudManager.sharedManger.importAllPencilsForProduct(self.product, modifiedAfterDate: modificationDate ){ (success, error) in
            self.tableView.isUserInteractionEnabled = true
            if !forced {
                self.hideSmallHUD()
            } else {
                self.refreshControl?.endRefreshing()
            }
            if let error = error {
                self.presentErrorAlert(title: NSLocalizedString("Unable to Update", comment:"update failed alert title"), message: NSLocalizedString("Please verify that you are connected to the Internet and that you are signed into iCloud.", comment:"icloud update failed message"))
                print(error.localizedDescription)
            } else {
                if let pencils = try? Pencil.allPencils(forProduct: self.product, context: self.product.managedObjectContext!) {
                    self.pencils = pencils ?? [Pencil]()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func recentModificationDate(inPencils pencils: [Pencil]) -> Date {
        if pencils.count == 0 {
            return Date(timeIntervalSinceReferenceDate: 0)
        }
        let newestPencil =  pencils.reduce(pencils.first!) { (p1: Pencil, p2: Pencil) -> Pencil in
            let date1 = p1.modificationDate ?? Date(timeIntervalSinceReferenceDate: 0)
            let date2 = p2.modificationDate ?? Date(timeIntervalSinceReferenceDate: 0)
            if date1.compare(date2) == ComparisonResult.orderedDescending {
                return p1
            }
            return p2
        }
        return newestPencil.modificationDate as Date? ?? Date()
    }

    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pencils.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PencilTableViewCell.nibName, for: indexPath) as! PencilTableViewCell
        cell.accessoryType = .disclosureIndicator
        let pencil = self.pencils[indexPath.row]
        cell.name = pencil.name
        cell.pencilIdentifier = pencil.identifier
        cell.colorSwatch = pencil.color as? UIColor
        cell.presentInInventory = (pencil.inventory != nil)
        return cell
    }

    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var pencil: Pencil
        if tableView == searchResultsTableController.tableView {
            pencil = self.searchResultsTableController.searchResults[indexPath.row]
        } else {
            pencil = self.pencils[indexPath.row]
        }
        
        let viewController = EditPencilTableViewController(pencil: pencil)
        
        if self.presentedViewController == self.searchController {
            self.dismiss(animated: true) {
                self.navigationController?.pushViewController(viewController, animated: true)
                self.searchController.searchBar.text = nil
            }
        } else {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

// MARK: search extensions

extension SelectPencilTableViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
 
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as! PencilSearchResultsTableViewController
        
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]

        let identifierPredicate = NSPredicate(format: "identifier contains[cd] %@", strippedString)
        
        var criteria = NSPredicate()
        
        let nameSubpredicates = searchItems.map{
            return NSPredicate(format: "name contains[cd] %@", $0)
        }
        if nameSubpredicates.count > 1 {
            criteria = NSCompoundPredicate(andPredicateWithSubpredicates: nameSubpredicates)
        } else {
            criteria = nameSubpredicates.first!
        }

        let searchPredicate = NSCompoundPredicate(type: .or, subpredicates: [criteria, identifierPredicate])
        
        let results = self.pencils.filter{ searchPredicate.evaluate(with: $0) }
        
        resultsController.searchResults = results
        resultsController.tableView.reloadData()
    }
    
}


