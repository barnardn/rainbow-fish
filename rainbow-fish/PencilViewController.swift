//
//  PencilViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
import CoreData
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
        self.tableView.registerClass(ProductFooterView.self, forHeaderFooterViewReuseIdentifier: "ProductFooterView")
        self.tableView!.rowHeight = ProductTableViewCell.estimatedRowHeight
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonTapped:"))
        addButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = addButton
        navigationItem.backBarButtonItem = self.backButton;
    }
    
    // MARK: button action
    
    func addButtonTapped(sender: UIBarButtonItem) {
        let viewController = EditManufacturerNavigationController(manufacturer: nil) { (didSave, edittedText) -> Void in
            if !didSave {
                return
            }
            let manufacturer = Manufacturer(managedObjectContext: CoreDataKit.mainThreadContext)
            let name = edittedText
            manufacturer.name = name
            var error: NSError?
            if !CoreDataKit.mainThreadContext.save(&error) {
                assertionFailure(error!.localizedDescription)
            } else {
                self.syncManufacturer(manufacturer, completionHandler: { [unowned self] (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.updateDatasource()
                })
            }
        }
        self.presentViewController(viewController, animated: true, completion: nil)
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
    
    private func syncManufacturer(manufacturer: Manufacturer, completionHandler: ((Bool, NSError?) -> Void)) {
        let record = manufacturer.toCKRecord()
        self.showHUD()
        
        CloudManager.sharedManger.syncChangeSet([record], completion: { (success, savedRecords, error) -> Void in
            self.hideHUD()
            assert(success, error!.localizedDescription)
            if let results = savedRecords {
                if let rec = results.first {
                    manufacturer.populateFromCKRecord(rec)
                }
            }
            var saveError: NSError?
            CoreDataKit.mainThreadContext.save(&saveError)
            if let parentContext = CoreDataKit.mainThreadContext.parentContext {
                parentContext.save(&saveError)
            }
            if let error = saveError {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(false, error) }
                return
            }
            dispatch_async(dispatch_get_main_queue()) { completionHandler(true, nil) }
        })
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

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerview = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProductFooterView") as ProductFooterView
        let manufacturer = allManufacturers[section] as Manufacturer
        footerview.manufacturer = manufacturer
        footerview.delegate = self
        return footerview
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductHeaderView.headerHeight;
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return ProductFooterView.footerHeight
    }
    
}

extension PencilViewController: ProductFooterViewDelegate {
    
    func productFooterView(view: ProductFooterView, newProductForManufacturer manufacturer: Manufacturer) {
        let viewController = EditProductNavigationController(product: nil) { [unowned self] (didSave, edittedText) -> Void in
            if didSave {
                let name = edittedText
                if let context = manufacturer.managedObjectContext {
                    let product = Product(managedObjectContext: context)
                    product.name = name
                    manufacturer.addProductsObject(product)
                    var error: NSError?
                    let ok = context.save(&error)
                    assert(ok, "unable to save: \(error?.localizedDescription)")
                    self.syncProduct(product, forManufacturer: manufacturer, completion: { [unowned self] (success, error) -> Void in
                        assert(success, error!.localizedDescription)
                        self.updateDatasource()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    private func syncProduct(product: Product, forManufacturer manufacturer: Manufacturer, completion: ((Bool, NSError?) -> Void)) {
        let productRecord = product.toCKRecord()
        productRecord.assignParentReference(parentRecord: manufacturer.toCKRecord(), relationshipName: ProductRelationships.manufacturer.rawValue)
        self.showHUD()
        CloudManager.sharedManger.syncChangeSet([productRecord], completion: { (success, returnedRecords, error) -> Void in
            self.hideHUD()
            assert(success, error!.localizedDescription)
            product.managedObjectContext?.performBlock({(_) in
                if let results = returnedRecords {
                    if let rec = results.first {
                        product.populateFromCKRecord(rec)
                    }
                }
                return .SaveToPersistentStore
                }, completionHandler: { [unowned self] (result: Result<CommitAction>) in
                    if let error = result.error() {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
            })
            
        })
    }
    
    
}


