//
//  EditPencilTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/15/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CloudKit
import CoreData
import CoreDataKit
import UIKit


class EditPencilTableViewController: ContentTableViewController {

    private var pencil: Pencil!
    private var context: NSManagedObjectContext!
    private var newPencil: Bool = false
    private var product: Product?
    private var editPenilKVOContext = 0
    private var recordCreatorID : String? = ""       // thread safety!
    
    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("saveButonTapped:"))
        return button
    }()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editButtonTapped:"))
        return button
    }()

    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelButtonTapped:"))
        return button
    }()
    
    convenience init(pencil: Pencil?) {
        self.init(style: UITableViewStyle.Grouped)
        self.recordCreatorID = AppController.appController.appConfiguration.iCloudRecordID
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, parentContext: CDK.mainThreadContext)
        if let editPencil = pencil {
            self.title = editPencil.name ?? NSLocalizedString("Edit Pencil", comment:"edit an existing pencil view title")
            self.pencil = self.context.objectWithID(editPencil.objectID) as! Pencil
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("inventoryDeletedNotificationHandler:"), name: NSManagedObjectContextDidSaveNotification, object: nil)
        } else {
            self.title = NSLocalizedString("New Pencil", comment:"new pencil view title")
            self.pencil = Pencil(managedObjectContext: self.context)
            self.pencil.ownerRecordIdentifier = self.recordCreatorID
            self.newPencil = true
        }

    }
    
    convenience init(product: Product) {
        self.init(pencil: nil)
        self.product = product
        self.pencil.product = self.context.objectWithID(self.product!.objectID) as? Product
    }
    
    deinit {
        self.observePencilChanges(false)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .FullScreen
        self.tableView.registerNib(UINib(nibName: EditPecilPropertyTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: EditPecilPropertyTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorPickerTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorPickerTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        if self.pencil.isMyPencil() && self.recordCreatorID == AppController.appController.dataImportKey {
            self.navigationItem.rightBarButtonItem = self.editButton
        }
        if self.newPencil {
            self.navigationItem.leftBarButtonItem = self.cancelButton
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.editing = true
        }
        self.observePencilChanges(true)
    }
    
    // MARK: kvo notification handler
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != &editPenilKVOContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        if !self.tableView.editing {
            return
        }
        if self.pencil.canSave() {
            self.navigationItem.setRightBarButtonItem(self.saveButton, animated: true)
        } else {
            self.navigationItem.setRightBarButtonItem(nil, animated: true)
        }
    }
    
    private func observePencilChanges(observe: Bool) {
        if observe {
            self.pencil.addObserver(self, forKeyPath: PencilAttributes.name.rawValue, options: .New, context: &editPenilKVOContext)
            self.pencil.addObserver(self, forKeyPath: PencilAttributes.identifier.rawValue, options: .New, context: &editPenilKVOContext)
        } else {
            self.pencil.removeObserver(self, forKeyPath: PencilAttributes.name.rawValue, context: &editPenilKVOContext)
            self.pencil.removeObserver(self, forKeyPath: PencilAttributes.identifier.rawValue, context: &editPenilKVOContext)
        }
    }
    
    // MARK: managedObjectContext changed notification handler
    
    func inventoryDeletedNotificationHandler(notification: NSNotification) {
        if let deletedSet = notification.userInfo?[NSDeletedObjectsKey] as? NSSet,
            let deletedObjects = deletedSet.allObjects as? [NSManagedObject]  {
            let matching = deletedObjects.filter{ $0.objectID == self.pencil.inventory?.objectID }
            if matching.count > 0 {
                self.context.mergeChangesFromContextDidSaveNotification(notification)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: button actions
    
    func editButtonTapped(sender: UIBarButtonItem) {
        self.navigationItem.setRightBarButtonItem(self.saveButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(self.cancelButton, animated: true)
        self.toggleEditing(true)
    }

    func cancelButtonTapped(sender: UIBarButtonItem) {
        if self.newPencil {
            self.tableView.endEditing(true)
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        self.observePencilChanges(false)
        self.navigationItem.setRightBarButtonItem(self.editButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.context.rollback()
        self.pencil = self.context.objectWithID(self.pencil.objectID) as! Pencil
        self.toggleEditing(false)
        self.observePencilChanges(true)
    }
    
    func saveButonTapped(sender: UIBarButtonItem) {
        
        self.tableView.endEditing(true)
        sender.enabled = false
        self.context.performBlock(
            { [unowned self] (_) in
                if let lineItem = self.pencil.inventory {
                    lineItem.populateWithPencil(self.pencil)
                }
                return .SaveToPersistentStore
            }, completionHandler: {[unowned self] (result) in
                do {
                    try result()
                    let pencilRecord = self.pencil.toCKRecord()
                    if self.newPencil {
                        if let product = self.product {
                            pencilRecord.assignParentReference(parentRecord: product.toCKRecord(), relationshipName: PencilRelationships.product.rawValue)
                        }
                    }
                    let userInfo = [AppNotificationInfoKeys.DidEditPencilPencilKey.rawValue : self.pencil]
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(AppNotifications.DidEditPencil.rawValue, object: nil, userInfo: userInfo)
                    })
                    self.cloudStoreRecords([pencilRecord])
                } catch {
                    assertionFailure()
                }
        })
    }
    
    private func toggleEditing(editing: Bool) {
        self.tableView.beginUpdates()
        self.tableView.setEditing(editing, animated: true)
        if editing {
            self.tableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
        } else {
            self.tableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
        }
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
    
    private func cloudStoreRecords(records: [CKRecord]) {
        self.showHUD()
        CloudManager.sharedManger.syncChangeSet(records){ [unowned self] (success, returnedRecords, error) -> Void in
            self.hideHUD()
            self.saveButton.enabled = true
            if !success {
                print(error?.localizedDescription)
                print(error?.userInfo)
                assertionFailure("bummer: \(error?.localizedDescription)")
            }
            self.context.performBlock({ [unowned self] (_) in
                if let results = returnedRecords {
                    if let rec = results.first {
                        self.pencil.populateFromCKRecord(rec)
                    }
                }
                return .SaveToPersistentStore
            }, completionHandler: { [unowned self] (result) in
                
                do {
                    try result()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if self.newPencil {
                            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            self.toggleEditing(false)
                            self.navigationItem.leftBarButtonItem = nil
                            self.navigationItem.rightBarButtonItem = self.editButton
                        }
                    })
                } catch {
                    assertionFailure()
                }
            })
        }
    }
    
    // MARK: inventory management methods
    
    
    private func addPencilToInventory() {
        
        self.context.performBlock({ [unowned self] (context: NSManagedObjectContext) in
                let inventory = Inventory(managedObjectContext: context)
                let pencil = context.objectWithID(self.pencil.objectID) as! Pencil
                inventory.populateWithPencil(pencil)
                return .SaveToPersistentStore
            },
            completionHandler: { [unowned self] (result) in
                
                do {
                    try result()
                    let userInfo = [AppNotificationInfoKeys.DidEditPencilPencilKey.rawValue : self.pencil.objectID ]
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(AppNotifications.DidEditPencil.rawValue, object: nil, userInfo: userInfo)
                    })
                } catch {
                    assertionFailure()
                }
            })
    }
    

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.newPencil {
            return 2
        }
        return (self.tableView.editing) ? 2 : 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 2 : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(EditPecilPropertyTableViewCell.nibName, forIndexPath: indexPath) as! EditPecilPropertyTableViewCell
            cell.pencil = self.pencil
            if indexPath.row == 0 {
                cell.placeholder = NSLocalizedString("Color Name", comment:"edit pencil color name placeholder")
                cell.keyPath = PencilAttributes.name.rawValue
            } else {
                cell.placeholder = NSLocalizedString("Color Code e.g. PC1097", comment:"edit pencil color code placeholder")
                cell.keyPath = PencilAttributes.identifier.rawValue
            }
            return cell
        } else if indexPath.section == 1 {
            if !self.tableView.editing {
                let cell = tableView.dequeueReusableCellWithIdentifier(PencilColorTableViewCell.nibName, forIndexPath: indexPath) as! PencilColorTableViewCell
                let color = self.pencil.color as? UIColor ?? UIColor.blackColor()
                cell.swatchColor = color
                cell.colorName = color.hexRepresentation
                return cell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(PencilColorPickerTableViewCell.nibName, forIndexPath: indexPath) as! PencilColorPickerTableViewCell
            cell.defaultColor = self.pencil.color as! UIColor? ?? UIColor.blackColor()
            cell.delegate = self
            return cell
        } else {
            let title = (self.pencil.inventory != nil) ? NSLocalizedString("You own this pencil.", comment:"edit pencil button title") : NSLocalizedString("Add Pencil To My Inventory", comment:"edit pencil add pencil to inventory button title")
            let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName) as! BigButtonTableViewCell
            cell.title = title
            cell.disabled = (self.pencil.inventory != nil)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.tableView.editing {
            return (indexPath.section != 1)
        }
        return false
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.tableView.editing {
            if indexPath.section == 0 {
                return 50.0
            } else {
                return PencilColorPickerTableViewCell.preferredRowHeight
            }
        }
        return 44.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.tableView.editing && self.pencil.name == nil {
            if indexPath.section == 0 && indexPath.row == 0 {
                cell.becomeFirstResponder()
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != 2 {
            return
        }
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BigButtonTableViewCell
        if !cell.disabled {
            self.addPencilToInventory()
            cell.title = NSLocalizedString("You own this pencil.", comment:"edit pencil button title")
            cell.disabled = true
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

extension EditPencilTableViewController: PencilColorPickerTableViewCellDelegate, UITextFieldDelegate {
    
    func colorPickerTableViewCell(cell: PencilColorPickerTableViewCell, didChangeColor color: UIColor) {
        self.pencil.color = color
    }
    
    func colorPickerTableViewCell(cell: PencilColorPickerTableViewCell, didRequestHexCodeWithColor color: UIColor?) {
        
        var hexTextField: UITextField?
        
        let alertController = UIAlertController(title: NSLocalizedString("Enter Hex Code", comment:"hex alert title"), message: NSLocalizedString("Enter the color code in hexadecimal e.g. \"0A41CD\"", comment:"hex alert message"), preferredStyle: .Alert)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"ok button title"), style: .Default) { [unowned self] (_) -> Void in
            if  let hexStr = hexTextField?.text,
                let color = UIColor.colorFromHexString(hexStr) {
                self.pencil.color = color
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
        })

        alertController.addTextFieldWithConfigurationHandler { [unowned self] (textField) -> Void in
            hexTextField = textField
            hexTextField?.textAlignment = .Center
            hexTextField?.delegate = self
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"cancel button title"), style: .Cancel, handler: nil))
        
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 {
            return true
        }
        if textField.text!.characters.count + string.characters.count > 6 {
            return false
        }
        let nonHexChars = NSCharacterSet(charactersInString: "0123456789ABCDEFabcdef").invertedSet
        if let _ = string.rangeOfCharacterFromSet(nonHexChars, options: NSStringCompareOptions.CaseInsensitiveSearch) {
            return false
        }
        return true
    }
    
    
}

