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

    var allManufacturers: [Manufacturer]?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(style: UITableViewStyle) {
        allManufacturers = [Manufacturer]()
        super.init(style: UITableViewStyle.Grouped)
        var image = UIImage(named: "tabbar-icon-pencils")?.imageWithRenderingMode(.AlwaysTemplate)
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("All Pencils", comment:"all pencils tab bar item title"), image: image, tag: 1)
        self.title = NSLocalizedString("Browse Pencils", comment:"browse all pencils navigation title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: ProductTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: ProductTableViewCell.nibName)
        self.tableView.registerClass(ProductHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProductHeaderView")
        self.tableView!.rowHeight = ProductTableViewCell.estimatedRowHeight
        updateDatasource()
        self.tableView!.reloadData()
    }
    
    func updateDatasource() {
        switch CoreDataKit.mainThreadContext.find(Manufacturer.self, predicate: nil, sortDescriptors: [NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)], limit: nil, offset: nil) {
            
        case let .Failure(error):
            assertionFailure(error.localizedDescription)
        case let .Success(boxedResults):
            self.allManufacturers = boxedResults()
        }
    }
}

extension PencilViewController: UITableViewDataSource, UITableViewDelegate {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return allManufacturers?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let manufacturer = allManufacturers![section] as Manufacturer
        return manufacturer.products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ProductTableViewCell.nibName, forIndexPath: indexPath) as ProductTableViewCell
        let product = productAtIndexPath(indexPath)
        cell.title = product?.name
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProductHeaderView") as ProductHeaderView
        let manufacturer = allManufacturers![section] as Manufacturer
        headerView.title = manufacturer.name
        return headerView
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductHeaderView.headerHeight;
    }
    
    func productAtIndexPath(indexPath: NSIndexPath) -> Product? {
        var manufacturer = allManufacturers![indexPath.section] as Manufacturer
        println(manufacturer.name)
        if let products = manufacturer.sortedProducts() {
            return products[indexPath.row]
        }
        return nil
    }
    
}
