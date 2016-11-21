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

    fileprivate var allManufacturers =  [Manufacturer]()
    fileprivate var recordCreatorID : String? = ""
    fileprivate var catalogContext = 0
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Catalog", comment:"all pencils back button title"), style: .plain, target: nil, action: nil)
        return button
    }()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(CatalogViewController.editButtonTapped(_:)))
        return button
    }()
    
    convenience init() {
        self.init(style: UITableViewStyle.grouped)
        self.title = NSLocalizedString("Catalog", comment:"catalog navigation title")
        NotificationCenter.default.addObserver(self, selector: #selector(CatalogViewController.updateDatasource), name: NSNotification.Name(rawValue: AppNotifications.DidFinishCloudUpdate.rawValue), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: ProductTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: ProductTableViewCell.nibName)
        self.tableView.register(ProductHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProductHeaderView")
        self.tableView.register(ProductFooterView.self, forHeaderFooterViewReuseIdentifier: "ProductFooterView")
        self.tableView!.rowHeight = ProductTableViewCell.estimatedRowHeight
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = AppearanceManager.appearanceManager.brandColor
        self.refreshControl?.addTarget(self, action: #selector(CatalogViewController.refreshControlDidChange(_:)), for: .valueChanged)

// NOTE: not allowing product and manufacturer inserts/edits at this point
        
//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonTapped:"))
//        addButton.tintColor = UIColor.whiteColor()
//        navigationItem.rightBarButtonItem = addButton
//        navigationItem.leftBarButtonItem = self.editButton
        
        navigationItem.backBarButtonItem = self.backButton
        self.recordCreatorID = AppController.appController.appConfiguration.iCloudRecordID;
        self.updateDatasource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppController.appController.shouldFetchCatalogOnDisplay {
            AppController.appController.shouldFetchCatalogOnDisplay = false
            self.updateDatasource()
        }
    }
    
    // MARK: button action
    
    func editButtonTapped(_ sender: UIBarButtonItem) {
        let editViewController = EditMfgTableViewController()
        self.navigationController?.setViewControllers([editViewController], animated: true)
    }
    
    func addButtonTapped(_ sender: UIBarButtonItem) {
        let viewController = EditManufacturerNavigationController(manufacturer: nil) { [unowned self] (didSave, edittedText, sender) -> Void in
            if !didSave {
                self.dismiss(animated: true, completion: nil)
                return
            }
            sender?.isEnabled = false
            guard let manufacturer = Manufacturer(managedObjectContext: CDK.mainThreadContext) else {
                return
            }
            manufacturer.ownerRecordIdentifier = self.recordCreatorID
            let name = edittedText
            manufacturer.name = name
            var error: NSError?
            do {
                try CDK.mainThreadContext.save()
                self.syncManufacturer(manufacturer, completionHandler: { [unowned self] (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        sender?.isEnabled = true
                        assertionFailure(error.localizedDescription)
                    }
                    self.dismiss(animated: true, completion: nil)
                    self.updateDatasource()
                })
            } catch let error1 as NSError {
                error = error1
                sender?.isEnabled = true
                assertionFailure(error!.localizedDescription)
            } catch {
                fatalError()
            }
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    func refreshControlDidChange(_ sender: UIRefreshControl) {
        self.cloudUpdate()
    }
    
    fileprivate func cloudUpdate() {
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
    
    fileprivate func syncManufacturer(_ manufacturer: Manufacturer, completionHandler: @escaping ((Bool, NSError?) -> Void)) {
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
            if let parentContext = CDK.mainThreadContext.parent {
                do {
                    try parentContext.save()
                } catch let error as NSError {
                    saveError = error
                } catch {
                    fatalError()
                }
            }
            if let error = saveError {
                DispatchQueue.main.async { completionHandler(false, error) }
                return
            }
            DispatchQueue.main.async { completionHandler(true, nil) }
        })
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allManufacturers.count 
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let manufacturer = allManufacturers[section] as Manufacturer
        return manufacturer.products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.nibName, for: indexPath) as! ProductTableViewCell
        let product = productAtIndexPath(indexPath)
        cell.title = product?.name
        return cell
    }
    
    func productAtIndexPath(_ indexPath: IndexPath) -> Product? {
        let manufacturer = allManufacturers[indexPath.section] as Manufacturer
        if let products = manufacturer.sortedProducts() {
            return products[indexPath.row]
        }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let product = productAtIndexPath(indexPath) {
            self.navigationController?.pushViewController(SelectPencilTableViewController(product: product), animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProductHeaderView") as! ProductHeaderView
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductHeaderView.headerHeight;
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return ProductFooterView.footerHeight
    }
    
}

extension CatalogViewController: ProductFooterViewDelegate {
    
    func productFooterView(_ view: ProductFooterView, newProductForManufacturer manufacturer: Manufacturer) {
        let viewController = EditProductNavigationController(product: nil) { [unowned self] (didSave, edittedText, sender) -> Void in
            if didSave {
                sender?.isEnabled = false
                let name = edittedText
                if let context = manufacturer.managedObjectContext {
                    let product = Product(managedObjectContext: context)!
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
                        sender?.isEnabled = true
                    }
                    self.syncProduct(product, forManufacturer: manufacturer, completion: { [unowned self] (success, error) -> Void in
                        assert(success, error!.localizedDescription)
                        self.updateDatasource()
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    fileprivate func syncProduct(_ product: Product, forManufacturer manufacturer: Manufacturer, completion: @escaping ((Bool, NSError?) -> Void)) {
        let productRecord = product.toCKRecord()
        productRecord.assignParentReference(parentRecord: manufacturer.toCKRecord(), relationshipName: ProductRelationships.manufacturer.rawValue)
        self.showHUD()
        CloudManager.sharedManger.syncChangeSet([productRecord], completion: { (success, returnedRecords, error) -> Void in
            self.hideHUD()
            assert(success, error!.localizedDescription)
            product.managedObjectContext?.perform(block: {(_) in
                if let results = returnedRecords {
                    if let rec = results.first {
                        product.populateFromCKRecord(rec)
                    }
                }
                return .saveToPersistentStore
                }, completionHandler: { (result) -> Void in
                    do {
                        let _ = try result()
                        completion(false, nil)
                    } catch let error as NSError {
                        completion(true, error)
                    }
            })
            
        })
    }
    
    
}


