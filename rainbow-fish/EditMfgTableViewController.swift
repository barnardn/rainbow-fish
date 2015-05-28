//
//  EditMfgTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 5/26/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CoreData
import CoreDataKit
import UIKit

class EditMfgTableViewController: UITableViewController {

    private var allManufacturers = [Manufacturer]()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelButtonTapped:"))
        return button
    }()
    
    convenience init() {
        self.init(style: UITableViewStyle.Grouped)
//        self.title = NSLocalizedString("Catalog", comment:"edit mfg and products title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(DefaultTableViewCell.self, forCellReuseIdentifier: DefaultTableViewCell.nibName as String)
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.updateDatasource()
    }

    private func updateDatasource() {
        switch CDK.mainThreadContext.find(Manufacturer.self, predicate: nil, sortDescriptors: [NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)], limit: nil, offset: nil) {
            
        case let .Failure(error):
            assertionFailure(error.localizedDescription)
        case let .Success(boxedResults):
            self.allManufacturers = boxedResults.value
        }
        self.tableView!.reloadData()
    }
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        let viewController = CatalogViewController()
        self.navigationController?.setViewControllers([viewController], animated: true)
    }
    
}

extension EditMfgTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.allManufacturers.count;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mfg = self.allManufacturers[section]
        return mfg.products.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DefaultTableViewCell.nibName as String, forIndexPath: indexPath) as! DefaultTableViewCell
        let mfg = self.allManufacturers[indexPath.section]
        if indexPath.row == 0 {
            cell.textLabel?.text = mfg.name
        } else {
            if let products = mfg.sortedProducts() {
                let product = products[indexPath.row - 1]
                cell.textLabel?.text = product.name
            }
        }
        return cell
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return (indexPath.row == 0) ? 0 : 1;
    }
    
}
