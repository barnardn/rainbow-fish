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

class CatalogViewController: ContentTableViewController {

    private var allManufacturers =  [Manufacturer]()
    private var recordCreatorID : String? = ""
    private var catalogContext = 0
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Catalog", comment:"all pencils back button title"), style: .Plain, target: nil, action: nil)
        return button
    }()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editButtonTapped:"))
        return button
    }()
    
    convenience init() {
        self.init(style: UITableViewStyle.Grouped)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateDatasource"), name: AppNotifications.DidFinishCloudUpdate.rawValue, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: ProductTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: ProductTableViewCell.nibName)
        self.tableView.registerClass(ProductHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProductHeaderView")
        self.tableView.registerClass(ProductFooterView.self, forHeaderFooterViewReuseIdentifier: "ProductFooterView")
        self.tableView!.rowHeight = ProductTableViewCell.estimatedRowHeight
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = AppearanceManager.appearanceManager.brandColor
        self.refreshControl?.addTarget(self, action: Selector("refreshControlDidChange:"), forControlEvents: .ValueChanged)
            
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonTapped:"))
        addButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = addButton
        navigationItem.backBarButtonItem = self.backButton
        navigationItem.leftBarButtonItem = self.editButton
        self.recordCreatorID = AppController.appController.appConfiguration.iCloudRecordID;
        self.updateDatasource()
        
    }
    
    
    // MARK: button action
    
    func editButtonTapped(sender: UIBarButtonItem) {
        let editViewController = EditMfgTableViewController()
        self.navigationController?.setViewControllers([editViewController], animated: true)
    }
    
    func addButtonTapped(sender: UIBarButtonItem) {
        let viewController = EditManufacturerNavigationController(manufacturer: nil) { [unowned self] (didSave, edittedText, sender) -> Void in
            if !didSave {
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            sender?.enabled = false
            let manufacturer = Manufacturer(managedObjectContext: CDK.mainThreadContext)
            manufacturer.ownerRecordIdentifier = self.recordCreatorID
            let name = edittedText
            manufacturer.name = name
            var error: NSError?
            if !CDK.mainThreadContext.save(&error) {
                sender?.enabled = true
                assertionFailure(error!.localizedDescription)
            } else {
                self.syncManufacturer(manufacturer, completionHandler: { [unowned self] (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        sender?.enabled = true
                        assertionFailure(error.localizedDescription)
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.updateDatasource()
                })
            }
        }
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func refreshControlDidChange(sender: UIRefreshControl) {
        self.cloudUpdate()
    }
    
    private func cloudUpdate() {
        CloudManager.sharedManger.refreshManufacturersAndProducts { [unowned self] (success, error) in
            if let e = error {
                assertionFailure(e.localizedDescription)
            }
            self.refreshControl?.endRefreshing()
            self.updateDatasource()
        }
    }
    
    func updateDatasource() {
        switch CDK.mainThreadContext.find(Manufacturer.self, predicate: nil, sortDescriptors: [NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)], limit: nil, offset: nil) {
            
        case let .Failure(error):
            assertionFailure(error.localizedDescription)
        case let .Success(boxedResults):
            println("pencilviewcontroller all manufacturer")
            self.allManufacturers = boxedResults.value
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
            CDK.mainThreadContext.save(&saveError)
            if let parentContext = CDK.mainThreadContext.parentContext {
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

extension CatalogViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return allManufacturers.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let manufacturer = allManufacturers[section] as Manufacturer
        return manufacturer.products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ProductTableViewCell.nibName, forIndexPath: indexPath) as! ProductTableViewCell
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

extension CatalogViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let product = productAtIndexPath(indexPath) {
            self.navigationController?.pushViewController(SelectPencilTableViewController(product: product), animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProductHeaderView") as! ProductHeaderView
        let manufacturer = allManufacturers[section] as Manufacturer
        headerView.title = manufacturer.name
        return headerView
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerview = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProductFooterView") as! ProductFooterView
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

extension CatalogViewController: ProductFooterViewDelegate {
    
    func productFooterView(view: ProductFooterView, newProductForManufacturer manufacturer: Manufacturer) {
        let viewController = EditProductNavigationController(product: nil) { [unowned self] (didSave, edittedText, sender) -> Void in
            if didSave {
                sender?.enabled = false
                let name = edittedText
                if let context = manufacturer.managedObjectContext {
                    let product = Product(managedObjectContext: context)
                    product.name = name
                    product.ownerRecordIdentifier = self.recordCreatorID
                    manufacturer.addProductsObject(product)
                    var error: NSError?
                    let ok = context.save(&error)
                    assert(ok, "unable to save: \(error?.localizedDescription)")
                    if !ok {
                        sender?.enabled = true
                    }
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


