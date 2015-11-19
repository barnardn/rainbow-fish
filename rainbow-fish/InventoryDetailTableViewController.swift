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

class InventoryDetailTableViewController: ContentTableViewController {

    enum InventorySection: Int {
        case Details, Color, Quantity, Delete
    }
    
    enum InventoryRow: Int {
        case Manufacturer, Product, ColorName, Color, Quantity, Delete
    }
    
    let sectionInfo: [[InventoryRow]] = [[.Manufacturer, .Product, .ColorName],
                                         [.Color], [.Quantity], [.Delete]]
    
    private var context: NSManagedObjectContext!
    private var lineItem: Inventory!
    private var editPencilColor: Bool = false

    var itemUpdatedBlock: ((lineItemWithIdentity: NSManagedObjectID, wasDeleted: Bool) -> Void)?
    
    convenience init(lineItem: Inventory) {
        self.init(style: UITableViewStyle.Grouped)
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, parentContext: CDK.mainThreadContext)
        self.context.undoManager = nil
        self.lineItem = self.context.objectWithID(lineItem.objectID) as? Inventory
        self.title = self.lineItem.name
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("contextDidSave:"), name: NSManagedObjectContextDidSaveNotification, object: self.context)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = CGFloat(44.0)
        self.tableView.registerNib(UINib(nibName: DefaultTableViewCell.nibName as String, bundle: nil), forCellReuseIdentifier: DefaultTableViewCell.nibName as String)
        self.tableView.registerNib(UINib(nibName: DefaultDetailTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultDetailTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: InventoryQuantityTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: InventoryQuantityTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorPickerTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorPickerTableViewCell.nibName)
    }

    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if self.context.hasChanges && parent == nil {
            self.saveChanges()
        }
        
    }
    
    // MARK: context notification handler
    
    
    func contextDidSave(notification: NSNotification) {
        
        if  let userInfo = notification.userInfo,
            let itemSet = userInfo[NSDeletedObjectsKey] as? NSSet,
            let block = self.itemUpdatedBlock
            where itemSet.count > 0 {
                block(lineItemWithIdentity: self.lineItem.objectID, wasDeleted: true)
        }        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: private api
    
    private func saveChanges() {
        self.context.performBlock( {(ctx: NSManagedObjectContext) in
            return .SaveToPersistentStore
            }, completionHandler: {[unowned self] (result) in
                do {
                    try result()
                    if let block = self.itemUpdatedBlock {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            block(lineItemWithIdentity: self.lineItem.objectID, wasDeleted: false)
                        })
                    }
                } catch {
                    assertionFailure()
                }
            })
    }
    
    
    
    // MARK: - Table view data source

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
            let cell = tableView.dequeueReusableCellWithIdentifier(DefaultTableViewCell.nibName as String, forIndexPath: indexPath) as! DefaultTableViewCell
            configureDetailCell(cell, atIndexPath: indexPath)
            return cell
        case (0, 2):
            let cell = tableView.dequeueReusableCellWithIdentifier(DefaultDetailTableViewCell.nibName, forIndexPath: indexPath) as! DefaultDetailTableViewCell
            cell.textLabel?.text = self.lineItem.name
            cell.detailTextLabel?.text = self.lineItem.pencilIdentifier
            cell.selectionStyle = .None
            return cell
        case (1, _):
            if self.editPencilColor {
                let cell = tableView.dequeueReusableCellWithIdentifier(PencilColorPickerTableViewCell.nibName, forIndexPath: indexPath) as! PencilColorPickerTableViewCell
                self.configureColorPickerCell(cell, atIndexPath: indexPath)
                return cell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(PencilColorTableViewCell.nibName, forIndexPath: indexPath) as! PencilColorTableViewCell
            configureColorSwatchCell(cell, atIndexPath: indexPath)
            return cell
        case (2, _) :
            let cell = tableView.dequeueReusableCellWithIdentifier(InventoryQuantityTableViewCell.nibName, forIndexPath: indexPath) as! InventoryQuantityTableViewCell
            configureQuantityCell(cell, atIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as! BigButtonTableViewCell
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
        cell.accessoryType = .DisclosureIndicator
        cell.selectionStyle = .None
    }
    
    private func configureColorPickerCell(cell: PencilColorPickerTableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.defaultColor = self.lineItem.color as! UIColor? ?? UIColor.blackColor()
        cell.delegate = self
    }
    
    private func configureQuantityCell(cell: InventoryQuantityTableViewCell, atIndexPath indexPath: NSIndexPath ) {
        cell.lineItem = self.lineItem        
    }
    
    
    private func configureButtonCell(cell: BigButtonTableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.destructiveButton = true
        cell.title = NSLocalizedString("Remove From My Inventory", comment:"remove pencil from inventory button title")
    }
    
    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == InventorySection.Color.rawValue {
            self.editPencilColor = !self.editPencilColor // ? false : true
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
            return
        }

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
                }, completionHandler: {(result) in
                    do {
                        try result()
                    } catch {
                        assertionFailure()
                    }
            })
        }))
        self.presentViewController(confirmController, animated: true, completion: nil);
        confirmController.view.tintColor = AppearanceManager.appearanceManager.brandColor
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 46.0
        } else if indexPath.section == InventorySection.Color.rawValue && self.editPencilColor {
            return PencilColorPickerTableViewCell.preferredRowHeight
        }
        return 44.0
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

extension InventoryDetailTableViewController: PencilColorPickerTableViewCellDelegate, UITextFieldDelegate {
    
    func colorPickerTableViewCell(cell: PencilColorPickerTableViewCell, didChangeColor color: UIColor) {
        self.lineItem.color = color
    }
    
    func colorPickerTableViewCell(cell: PencilColorPickerTableViewCell, didRequestHexCodeWithColor color: UIColor?) {
        
        var hexTextField: UITextField?
        
        let alertController = UIAlertController(title: NSLocalizedString("Enter Hex Code", comment:"hex alert title"), message: NSLocalizedString("Enter the color code in hexadecimal e.g. \"0A41CD\"", comment:"hex alert message"), preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"ok button title"), style: .Default) { [unowned self] (_) -> Void in
            if  let hexStr = hexTextField?.text,
                let color = UIColor.colorFromHexString(hexStr) {
                    self.lineItem.color = color
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
            })
        
        alertController.addTextFieldWithConfigurationHandler { [unowned self] (textField) -> Void in
            hexTextField = textField
            hexTextField?.textAlignment = .Center
            hexTextField?.delegate = self
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"cancel button title"), style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 {
            return true
        }
        if (textField.text?.characters.count)! + string.characters.count > 6 {
            return false
        }
        let nonHexChars = NSCharacterSet(charactersInString: "0123456789ABCDEFabcdef").invertedSet
        if let _ = string.rangeOfCharacterFromSet(nonHexChars, options: NSStringCompareOptions.CaseInsensitiveSearch) {
            return false
        }
        return true
    }
    
    
}
