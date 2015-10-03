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
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneButtonTapped:"))
        return button
    }()
    
    convenience init() {
        self.init(style: UITableViewStyle.Grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(DefaultTableViewCell.self, forCellReuseIdentifier: DefaultTableViewCell.nibName as String)
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.updateDatasource()
    }

    private func updateDatasource() {
        
        let results = try? CDK.mainThreadContext.find(Manufacturer.self, predicate: nil, sortDescriptors: [NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)], limit: nil, offset: nil)
        self.allManufacturers = results ?? [Manufacturer]()
        self.tableView!.reloadData()
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        let viewController = CatalogViewController()
        self.navigationController?.setViewControllers([viewController], animated: true)
    }
    
    func isOwnedByMe(object: CloudSyncable) -> Bool {
        return (object.ownerRecordIdentifier == AppController.appController.appConfiguration.iCloudRecordID)
    }
    
    func editManufacturer(mfg: Manufacturer) {
        let viewController = EditManufacturerNavigationController(manufacturer: mfg) { (didSave, edittedText, sender) -> Void in
            if !didSave {
                self.dismissViewControllerAnimated(true, completion: nil)
                return;
            }
            sender?.enabled = false
            mfg.managedObjectContext?.performBlock({ (context: NSManagedObjectContext) in
                mfg.name = edittedText
                return CommitAction.SaveToPersistentStore
            }, completionHandler: { (result) in
                sender?.enabled = true
                do {
                    try result()
                    self.syncEditsToCloud(mfg, completion: { [unowned self] () -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        self.tableView.reloadData()
                    })
                } catch {
                    assertionFailure()
                }
            })
        }
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func editProduct(product: Product) {
        let viewController = EditProductNavigationController(product: product) { (didSave, edittedText, sender) -> Void in
            if !didSave {
                self.dismissViewControllerAnimated(true, completion: nil)
                return;
            }
            sender?.enabled = false
            product.managedObjectContext?.performBlock({ (context: NSManagedObjectContext) in
                product.name = edittedText
                return CommitAction.SaveToPersistentStore
                }, completionHandler: { (result) in
                    sender?.enabled = true
                    do {
                        try result()
                        self.syncEditsToCloud(product) { [unowned self] in
                            self.dismissViewControllerAnimated(true, completion: nil)
                            self.tableView.reloadData()
                        }
                    } catch {
                        assertionFailure()
                    }
                })
        }
        self.presentViewController(viewController, animated: true, completion: nil)

    }
    
    func syncEditsToCloud(cloudObject: CloudSyncable, completion: () -> Void) {
        let record = cloudObject.toCKRecord()
        self.showHUD()
        CloudManager.sharedManger.syncChangeSet([record], completion: { [unowned self] (success, savedRecords, error) -> Void in
            self.hideHUD()
            dispatch_async(dispatch_get_main_queue()) { completion() }
        })
    }

    //MARK: tableview datasource
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.allManufacturers.count;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mfg = self.allManufacturers[section]
        return mfg.products.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DefaultTableViewCell.nibName as String, forIndexPath: indexPath) as! DefaultTableViewCell
        
        let cloudObject = self.cloudObjectAt(indexPath)
        if indexPath.row == 0 {
            let mfg = cloudObject as? Manufacturer
            cell.textLabel?.text = mfg?.name
        } else {
            let product = cloudObject as? Product
            cell.textLabel?.text = product?.name
        }
        return cell
    }

    //MARK: tableview delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cloudObject = self.cloudObjectAt(indexPath)
        if let mfg = cloudObject as? Manufacturer where indexPath.row == 0 {
            self.editManufacturer(mfg)
        } else if let product = cloudObject as? Product where indexPath.row > 0 {
            self.editProduct(product)
        }
    
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cloudObject = self.cloudObjectAt(indexPath)
        if self.isOwnedByMe(cloudObject) {
            cell.textLabel?.textColor = AppearanceManager.appearanceManager.blackColor
            cell.selectionStyle = .Blue
            cell.accessoryType = .DisclosureIndicator
        } else {
            cell.textLabel?.textColor = AppearanceManager.appearanceManager.disabledTitleColor
            cell.selectionStyle = .None
            cell.accessoryType = .None
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cloudObject = self.cloudObjectAt(indexPath)
        return self.isOwnedByMe(cloudObject) ? indexPath : nil
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return (indexPath.row == 0) ? 0 : 1;
    }
    
    private func cloudObjectAt(indexPath: NSIndexPath) -> CloudSyncable {
        let mfg = self.allManufacturers[indexPath.section]
        var cloudObject = mfg as CloudSyncable
        if indexPath.row > 0 {
            if let products = mfg.sortedProducts() {
                cloudObject = products[indexPath.row - 1]
            }
        }
        return cloudObject
    }
    
}
