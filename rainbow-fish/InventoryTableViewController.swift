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
    
    lazy var sortMethodSegmentedControl: UISegmentedControl = {
        
        let segControl =  UISegmentedControl(items: [
            NSLocalizedString("A-Z",  comment: "inventory sort alpha title"),
            NSLocalizedString("Least - Most", comment: "inventory tab sort lest to most title")])
        
        segControl.selectedSegmentIndex = InventorySortModes.Alpha.rawValue
        segControl.tintColor = AppearanceManager.appearanceManager.brandColorLight
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
    
    lazy var demoDataSource: [(String, String, Int)] = {
       return [
            ("Cadmium Blue", "Prismacolor PC 1097", 3),
            ("Forest Green", "Prismacolor PC 1015", 4),
            ("Ferrari Red", "Prismacolor PC 1032", 2),
            ("Arctic White", "Prismacolor PC 322", 1),
            ("Desert Jasmine", "Prismacolor PC 3237", 1)
        ]
        
    }()
    
    
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
        
        self.navigationItem.titleView = sortMethodSegmentedControl
        self.tableView!.rowHeight = UITableViewAutomaticDimension;
        self.tableView!.estimatedRowHeight = 60.0
        self.tableView!.registerNib(UINib(nibName: InventoryTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: InventoryTableViewCell.nibName)
        self.tableView!.tableHeaderView = self.searchBar
        self.searchBar.sizeToFit()        
    }
    
    func segmentControlChanged(sender: UISegmentedControl) {
        println("\(sender.selectedSegmentIndex)")
    }
    
    
}

extension InventoryTableViewController : UITableViewDataSource, UITableViewDelegate {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.demoDataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(InventoryTableViewCell.nibName, forIndexPath: indexPath) as InventoryTableViewCell
        let tuple = demoDataSource[indexPath.row]
        cell.title = tuple.0
        cell.subtitle = tuple.1
        cell.quantity = String(tuple.2)
        return cell
    }
    
}
    

extension InventoryTableViewController : UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        println("\(searchText)")
    }
    
}


