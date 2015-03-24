//
//  InventoryDetailTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/4/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CoreData
import CoreDataKit
import UIKit

class InventoryDetailTableViewController: UITableViewController {

    enum InventorySection: Int {
        case Details, Color, Quantity, Delete
    }
    
    enum InventoryRow: Int {
        case Manufacturer, Product, ColorName, Color, Quantity, Delete
    }
    
    lazy var doneButton : UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneButtonTapped:"))
        return button
    }()
    
    let sectionInfo: [[InventoryRow]] = [[.Manufacturer, .Product, .ColorName],
                                         [.Color], [.Quantity], [.Delete]]
    
    private var context: NSManagedObjectContext!
    private var lineItem: Inventory!

    var itemUpdatedBlock: ((lineItemWithIdentity: NSManagedObjectID, wasDeleted: Bool) -> Void)?
    
    convenience init(lineItem: Inventory) {
        self.init(style: UITableViewStyle.Grouped)
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, parentContext: CDK.mainThreadContext)
        self.context.undoManager = nil
        self.lineItem = self.context.objectWithID(lineItem.objectID) as? Inventory
        self.title = self.lineItem.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = CGFloat(44.0)
        self.tableView.registerNib(UINib(nibName: DefaultTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: DefaultDetailTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultDetailTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: InventoryQuantityTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: InventoryQuantityTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("contextDidChange:"), name: NSManagedObjectContextObjectsDidChangeNotification, object: self.context)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("contextWillSave:"), name: NSManagedObjectContextWillSaveNotification, object: self.context)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("contextDidSave:"), name: NSManagedObjectContextDidSaveNotification, object: self.context)
        
    }

    // MARK: done button handler
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.context.performBlock( {(ctx: NSManagedObjectContext) in
            return .SaveToPersistentStore
            }, completionHandler: {(result: Result<CommitAction>) in
                if let error = result.error() as NSError? {
                    assertionFailure(error.localizedDescription)
                } else {
                    if let block = self.itemUpdatedBlock {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            block(lineItemWithIdentity: self.lineItem.objectID, wasDeleted: false)
                        })
                    }
                }
        })
    }
    
    
    // MARK: context notification handlers
    
    func contextDidChange(notification: NSNotification) {
        self.navigationItem.setRightBarButtonItem(self.doneButton, animated: true)
    }
    
    func contextWillSave(notification: NSNotification) {
        self.navigationItem.setRightBarButtonItem(nil, animated: true)
    }
    
    func contextDidSave(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let itemSet = userInfo[NSDeletedObjectsKey] as? NSSet {
                if itemSet.count > 0 {
                    if let block = self.itemUpdatedBlock {
                        block(lineItemWithIdentity: self.lineItem.objectID, wasDeleted: true)
                    }
                }
            }
        }
        self.navigationController?.popViewControllerAnimated(true)        
    }
    
}

// MARK: - Table view data source

extension InventoryDetailTableViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionInfo.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDetail = self.sectionInfo[section]
        return sectionDetail.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch (indexPath.section, indexPath.row) {
        case (0,0...1):
            let cell = tableView.dequeueReusableCellWithIdentifier(DefaultTableViewCell.nibName, forIndexPath: indexPath) as DefaultTableViewCell
            configureDetailCell(cell, atIndexPath: indexPath)
            return cell
        case (0, 2):
            let cell = tableView.dequeueReusableCellWithIdentifier(DefaultDetailTableViewCell.nibName, forIndexPath: indexPath) as DefaultDetailTableViewCell
            cell.textLabel?.text = self.lineItem.name
            cell.detailTextLabel?.text = self.lineItem.pencilIdentifier
            cell.selectionStyle = .None
            return cell
        case (1, _):
            let cell = tableView.dequeueReusableCellWithIdentifier(PencilColorTableViewCell.nibName, forIndexPath: indexPath) as PencilColorTableViewCell
            configureColorSwatchCell(cell, atIndexPath: indexPath)
            return cell
        case (2, _) :
            let cell = tableView.dequeueReusableCellWithIdentifier(InventoryQuantityTableViewCell.nibName, forIndexPath: indexPath) as InventoryQuantityTableViewCell
            configureQuantityCell(cell, atIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as BigButtonTableViewCell
            configureButtonCell(cell, atIndexPath: indexPath)
            return cell
        }
        
    }
    
    private func configureDetailCell(cell: DefaultTableViewCell, atIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.textLabel?.text = self.lineItem.manufacturerName
        } else {
            cell.textLabel?.text = self.lineItem.productName
        }
        cell.selectionStyle = .None
    }
    
    private func configureColorSwatchCell(cell: PencilColorTableViewCell, atIndexPath indexPath: NSIndexPath) {
        if let color = self.lineItem.color as? UIColor {
            cell.colorName = color.hexRepresentation
            cell.swatchColor = color
        } else {
            cell.colorName = nil
            cell.swatchColor = nil
        }
        cell.selectionStyle = .None
    }
    
    private func configureQuantityCell(cell: InventoryQuantityTableViewCell, atIndexPath indexPath: NSIndexPath ) {
        cell.lineItem = self.lineItem        
    }
    
    
    private func configureButtonCell(cell: BigButtonTableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.destructiveButton = true
        cell.title = NSLocalizedString("Remove From My Inventory", comment:"remove pencil from inventory button title")
    }
    
}

// MARK: - Table view delegate

extension InventoryDetailTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != InventorySection.Delete.rawValue {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return
        }
        let pencilName = self.lineItem.name!
        let confirmController = UIAlertController(title: NSLocalizedString("Remove From Inventory", comment:"confirm pencil inventory item alert title"), message: NSLocalizedString("Are you sure you want to remove \"\(pencilName)\" from your inventory?", comment:"confirm pencil deletion message"), preferredStyle: .Alert)
        
        confirmController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        confirmController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { [unowned self] (_: UIAlertAction!) -> Void in
            self.context.performBlock({(context: NSManagedObjectContext) in
                
                context.deleteObject(self.lineItem)
                
                return .SaveToPersistentStore
                }, completionHandler: {(result: Result<CommitAction>) in
                    if let error = result.error() as NSError? {
                        assertionFailure(error.localizedDescription)
                    }
            })
        }))
        confirmController.view.tintColor = AppearanceManager.appearanceManager.brandColor
        self.presentViewController(confirmController, animated: true, completion: nil);
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case InventorySection.Details.rawValue:
            return NSLocalizedString("Pencil Details", comment:"inventory details  header title")
        case InventorySection.Color.rawValue:
            return NSLocalizedString("Color", comment:"inventory details color header title")
        case InventorySection.Quantity.rawValue:
            return NSLocalizedString("Quantity On Hand", comment:"inventory details quantity header title")
        default:
            return nil
        }
    }
    
    
    
    
}