//
//  SelectProductTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/8/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class SelectProductTableViewController: UITableViewController {

    var viewModel: PencilDataViewModel?
    var products: [Product]?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    convenience init(viewModel: PencilDataViewModel) {
        self.init(style: UITableViewStyle.Plain)
        self.viewModel = viewModel
        self.title = NSLocalizedString("Select Product", comment:"select product nav bar title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.registerNib(UINib(nibName: DefaultTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultTableViewCell.nibName)
        let byName = NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)
        products = viewModel?.manufacturer?.sortedProducts()
        tableView.reloadData()
    }

}


extension SelectProductTableViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let products = self.products {
            return products.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DefaultTableViewCell.nibName, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = AppearanceManager.appearanceManager.standardFont
        cell.textLabel?.textColor = AppearanceManager.appearanceManager.bodyTextColor
        cell.accessoryType = .None
        
        if let product = self.products?[indexPath.row] {
            if product.objectID == viewModel?.product?.objectID {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                cell.accessoryType = .Checkmark
            }
            cell.textLabel?.text = product.name
        }
        return cell
    }
    
}

extension SelectProductTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let product = self.products?[indexPath.row] {
            viewModel?.product = product
            let cell = tableView.cellForRowAtIndexPath(indexPath) as DefaultTableViewCell
            cell.accessoryType = .Checkmark
        }
    }
    
}