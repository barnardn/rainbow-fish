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
        self.title = NSLocalizedString("Catalog", comment:"catalog navigation title")
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

// NOTE: not allowing product and manufacturer inserts/edits at this point
        
//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonTapped:"))
//        addButton.tintColor = UIColor.whiteColor()
//        navigationItem.rightBarButtonItem = addButton
//        navigationItem.leftBarButtonItem = self.editButton
        
        navigationItem.backBarButtonItem = self.backButton
        
        self.recordCreatorID = AppController.appController.appConfiguration.iCloudRecordID;
        AppController.appController.shouldFetchCatalogOnDisplay = false
        self.updateDatasource()
        self.cloudUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if AppController.appController.shouldFetchCatalogOnDisplay {
            self.updateDatasource()
        }
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
            do {
                try CDK.mainThreadContext.save()
                self.syncManufacturer(manufacturer, completionHandler: { [unowned self] (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        sender?.enabled = true
                        assertionFailure(error.localizedDescription)
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.updateDatasource()
                })
            } catch let error1 as NSError {
                error = error1
                sender?.enabled = true
                assertionFailure(error!.localizedDescription)
            } catch {
                fatalError()
            }
        }
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func refreshControlDidChange(sender: UIRefreshControl) {
        self.cloudUpdate()
    }
    
    private func cloudUpdate() {
        if (!AppController.appController.icloudCurrentlyAvailable) {
            self.refreshControl?.endRefreshing()            
            return
        }
        CloudManager.sharedManger.refreshManufacturersAndProducts { [unowned self] (success, error) in
            self.refreshControl?.endRefreshing()
            if let _ = error {
                self.presentErrorAlert(title: NSLocalizedString("Unable to Update", comment:"update failed alert title"), message: NSLocalizedString("Please verify that you are connected to the Internet and that you are signed into iCloud.", comment:"icloud update failed message"))
            }
            self.updateDatasource()
        }
    }
    
    func updateDatasource() {
        
        let results = try? CDK.mainThreadContext.find(Manufacturer.self, predicate: nil, sortDescriptors: [NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)], limit: nil, offset: nil)
        if let results = results {
            self.allManufacturers = results
            AppController.appController.updateLastUpdatedDateToNow()
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
            do {
                try CDK.mainThreadContext.save()
            } catch let error as NSError {
                saveError = error
            } catch {
                fatalError()
            }
            if let parentContext = CDK.mainThreadContext.parentContext {
                do {
                    try parentContext.save()
                } catch let error as NSError {
                    saveError = error
                } catch {
                    fatalError()
                }
            }
            if let error = saveError {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(false, error) }
                return
            }
            dispatch_async(dispatch_get_main_queue()) { completionHandler(true, nil) }
        })
    }
    
    
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
        let manufacturer = allManufacturers[indexPath.section] as Manufacturer
        if let products = manufacturer.sortedProducts() {
            return products[indexPath.row]
        }
        return nil
    }
    
    
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

// REMOVED FOR NOW: need to research how to properly support this for multiple users!
//
    
//    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerview = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProductFooterView") as! ProductFooterView
//        let manufacturer = allManufacturers[section] as Manufacturer
//        footerview.manufacturer = manufacturer
//        footerview.delegate = self
//        return footerview
//    }
    
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
                    let ok: Bool
                    do {
                        try context.save()
                        ok = true
                    } catch let error1 as NSError {
                        error = error1
                        ok = false
                    } catch {
                        fatalError()
                    }
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
                }, completionHandler: { (result) -> Void in
                    do {
                        try result()
                        completion(false, nil)
                    } catch let error as NSError {
                        completion(true, error)
                    }
            })
            
        })
    }
    
    
}


