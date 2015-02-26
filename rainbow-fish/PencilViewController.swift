//
//  PencilViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
import CoreDataKit

class PencilViewController: ContentTableViewController {

    var allManufacturers =  [Manufacturer]()
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("All", comment:"all pencils back button title"), style: .Plain, target: nil, action: nil)
        return button
    }()
    
    convenience init() {
        self.init(style: UITableViewStyle.Grouped)
        var image = UIImage(named: "tabbar-icon-pencils")?.imageWithRenderingMode(.AlwaysTemplate)
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("All Pencils", comment:"all pencils tab bar item title"), image: image, tag: 1)
        self.title = NSLocalizedString("All Pencils", comment:"browse all pencils navigation title")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateDatasource"), name: AppNotifications.DidFinishCloudUpdate.rawValue, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: ProductTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: ProductTableViewCell.nibName)
        self.tableView.registerClass(ProductHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProductHeaderView")
        self.tableView!.rowHeight = ProductTableViewCell.estimatedRowHeight
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonTapped:"))
        addButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = addButton
        navigationItem.backBarButtonItem = self.backButton;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        struct Static {
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token, { () -> Void in
            self.updateDatasource()
        })
    }
    
    // MARK: button action
    
    func addButtonTapped(sender: UIBarButtonItem) {
        self.presentViewController(PencilProductNavigationController(nibName: nil, bundle: nil), animated: true, completion: nil)
    }
    
    func updateDatasource() {
        switch CoreDataKit.mainThreadContext.find(Manufacturer.self, predicate: nil, sortDescriptors: [NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)], limit: nil, offset: nil) {
            
        case let .Failure(error):
            assertionFailure(error.localizedDescription)
        case let .Success(boxedResults):
            self.allManufacturers = boxedResults()
        }
        self.tableView!.reloadData()
    }
}

extension PencilViewController: UITableViewDataSource, UITableViewDelegate {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return allManufacturers.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let manufacturer = allManufacturers[section] as Manufacturer
        return manufacturer.products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ProductTableViewCell.nibName, forIndexPath: indexPath) as ProductTableViewCell
        let product = productAtIndexPath(indexPath)
        cell.title = product?.name
        return cell
    }
    
    func productAtIndexPath(indexPath: NSIndexPath) -> Product? {
        var manufacturer = allManufacturers[indexPath.section] as Manufacturer
        if let products = manufacturer.sortedProducts() {
            return products[indexPath.row]
        }
        return nil
    }
    
}


extension PencilViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let product = productAtIndexPath(indexPath) {
            self.navigationController?.pushViewController(SelectPencilTableViewController(product: product), animated: true)
        }
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProductHeaderView") as ProductHeaderView
        let manufacturer = allManufacturers[section] as Manufacturer
        headerView.title = manufacturer.name
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductHeaderView.headerHeight;
    }
    
}



