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
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = NSLocalizedString("Search", comment:"inventory search bar placeholder")
        searchBar.delegate = self
        return searchBar
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
        self.tableView.tableHeaderView = self.searchBar
        self.searchBar.sizeToFit()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didEditPencil:"), name: AppNotifications.DidEditPencil.rawValue, object: nil)
        self.updateInventory()
    }
    
    func segmentControlChanged(sender: UISegmentedControl) {
        println("\(sender.selectedSegmentIndex)")
    }
    
    func updateInventory() {
        let results = Inventory.fullInventory(inContext: CoreDataKit.mainThreadContext)
        self.inventory = results ?? [Inventory]()
        self.tableView.reloadData()
    }
    
    // MARK: NSNotification handler
    
    func didEditPencil(notification: NSNotification) {
        self.updateInventory()
    }
    
}

extension InventoryTableViewController : UITableViewDataSource, UITableViewDelegate {
    
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


extension InventoryTableViewController : UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        println("\(searchText)")
    }
    
}


