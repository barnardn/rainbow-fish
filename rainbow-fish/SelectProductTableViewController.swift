//
//  SelectProductTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/8/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class SelectProductTableViewController: UITableViewController {

    var viewModel: PencilDataViewModel!
    var products: [Product]?
    
    lazy var addButton:  UIBarButtonItem = {
        var button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonTapped:"))
        return button
    }()
    
    convenience init(viewModel: PencilDataViewModel) {
        self.init(style: UITableViewStyle.Plain)
        self.viewModel = viewModel
        self.title = NSLocalizedString("Select Product", comment:"select product nav bar title")
        self.navigationItem.rightBarButtonItem = self.addButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.registerNib(UINib(nibName: DefaultTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultTableViewCell.nibName)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0        
        let byName = NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)
        products = viewModel.manufacturer?.sortedProducts()
        tableView.reloadData()
    }

    //MARK: button action
    
    func addButtonTapped(sender: UIBarButtonItem) {
        let viewController = EditManufacturerNavigationController(manufacturer: nil) { (didSave, edittedText) -> Void in
            if didSave {
                if let name = edittedText {
                    let product = Product(managedObjectContext: self.viewModel.childContext)
                    product.name = name
                    self.viewModel.manufacturer?.addProductsObject(product)
                    var error: NSError?
                    let ok = self.viewModel.childContext.save(&error)
                    assert(ok, "unable to save: \(error?.localizedDescription)")
                    self.insertProduct(product)
                }
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    private func insertProduct(product: Product) {
        var row = 0

        self.viewModel.product = product
        if var products = self.products {
            let idx = products.insertionIndexOf(product, isOrderedBefore: { (m1: Product, m2: Product) -> Bool in
                let name1 = m1.name
                let name2 = m2.name
                return (name1!.localizedCaseInsensitiveCompare(name2!) == .OrderedAscending)
            })
            row = idx
            products.insert(product, atIndex: idx)
            self.products = products
        } else {
            self.products = [product]
        }
        var indexPath = NSIndexPath(forRow: row, inSection: 0)
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
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
        cell.accessoryType = .None
        
        if let product = self.products?[indexPath.row] {
            if product.objectID == viewModel.product?.objectID {
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
            viewModel.product = product
            let cell = tableView.cellForRowAtIndexPath(indexPath) as DefaultTableViewCell
            cell.accessoryType = .Checkmark
        }
    }
    
}