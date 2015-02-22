//
//  PencilProductTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilProductTableViewController: UITableViewController {

    private var editContext = 0
    var sectionTitles = [String]()
    var viewModel: PencilDataViewModel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: .Grouped)
        sectionTitles.append(NSLocalizedString("Manufacturer", comment:"edit product manufacturer cell title"))
        viewModel = PencilDataViewModel()
        
        viewModel.addObserver(self, forKeyPath: "manufacturer", options: .New, context: &editContext)
        viewModel.addObserver(self, forKeyPath: "product", options: .New, context: &editContext)
        
    }
    
    deinit {
        viewModel.removeObserver(self, forKeyPath: "manufacturer")
        viewModel.removeObserver(self, forKeyPath: "product")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.rowHeight = 44.0
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneButtonTapped:"))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelButtonTapped:"))

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.title = NSLocalizedString("New Product", comment:"new product view controller navigation title")

    }
    
    // MARK: button actions
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: KVO observer methods
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &editContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        switch keyPath {
            case "manufacturer":
                let mnf = viewModel.manufacturer as Manufacturer!
                updateTableForSelectedManfufacturer(mnf)
            case "product":
                let prod = viewModel.product as Product?
                updateTableForSelectedProduct(prod)
            default:
                return
        }

    }
    
    private func updateTableForSelectedManfufacturer(manufacturer: Manufacturer) {
        var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as NameValueTableViewCell
        cell.value = manufacturer.name
        var sectionRows = self.sectionTitles[0]
        if self.sectionTitles.count == 1 {
            self.sectionTitles.append(NSLocalizedString("Product", comment:"edit product product cell title"))
            self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        }
    }
    
    private func updateTableForSelectedProduct(product: Product?) {
        if self.tableView.numberOfSections() == 2 {
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as NameValueTableViewCell
            cell.value = product?.name
        }
    }
    
}

extension PencilProductTableViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NameValueTableViewCell.nibName, forIndexPath: indexPath) as NameValueTableViewCell
        cell.name = titleForSection(atIndexPath: indexPath)
        cell.value = valueForSection(atIndexPath: indexPath)
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func titleForSection(atIndexPath indexPath: NSIndexPath) -> String? {
        return self.sectionTitles[indexPath.section]
    }
    
    func valueForSection(atIndexPath indexPath: NSIndexPath) -> String? {
        if indexPath.section == 0 {
            return viewModel.manufacturer?.name
        }
        return viewModel.product?.name
    }
}

extension PencilProductTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.navigationController?.pushViewController(SelectManufacturerTableViewController(viewModel: self.viewModel), animated: true)
        } else if indexPath.section == 1 {
            self.navigationController?.pushViewController(SelectProductTableViewController(viewModel: self.viewModel), animated: true)
        }
    }
    
}

