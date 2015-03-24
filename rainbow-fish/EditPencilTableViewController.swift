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


class EditPencilTableViewController: UITableViewController {

    private var pencil: Pencil!
    private var context: NSManagedObjectContext!
    private var newPencil: Bool = false
    private var product: Product?
    private var editPenilKVOContext = 0
    
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
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, parentContext: CDK.mainThreadContext)
        if let editPencil = pencil {
            self.title = editPencil.name ?? NSLocalizedString("Edit Pencil", comment:"edit an existing pencil view title")
            self.pencil = self.context.objectWithID(editPencil.objectID) as Pencil
        } else {
            self.title = NSLocalizedString("New Pencil", comment:"new pencil view title")
            self.pencil = Pencil(managedObjectContext: self.context)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .FullScreen
        self.tableView.registerNib(UINib(nibName: EditPecilPropertyTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: EditPecilPropertyTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorPickerTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorPickerTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        self.navigationItem.rightBarButtonItem = self.editButton
        if self.newPencil {
            self.navigationItem.leftBarButtonItem = self.cancelButton
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.editing = true
        }
        self.observePencilChanges(true)
    }

    // MARK: kvo notification handler
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
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
    
    
    
    // MARK: button actions
    
    func editButtonTapped(sender: UIBarButtonItem) {
        self.navigationItem.setRightBarButtonItem(self.saveButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(self.cancelButton, animated: true)
        self.toggleEditing(true)
    }

    func cancelButtonTapped(sender: UIBarButtonItem) {
        if self.newPencil {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        self.observePencilChanges(false)
        self.navigationItem.setRightBarButtonItem(self.editButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.context.rollback()
        self.pencil = self.context.objectWithID(self.pencil.objectID) as Pencil
        self.toggleEditing(false)
        self.observePencilChanges(true)
    }
    
    func saveButonTapped(sender: UIBarButtonItem) {
        
        self.tableView.endEditing(true)
        sender.enabled = false
        self.context.performBlock(
            {(_) in
                if let lineItem = self.pencil.inventory {
                    lineItem.populateWithPencil(self.pencil)
                }
                return .SaveToPersistentStore
            }, completionHandler: {[unowned self] (result: Result<CommitAction>) in
                switch result {
                case let .Failure(error):
                    sender.enabled = true
                    println("cant save \(error)")
                default:
                    let pencilRecord = self.pencil.toCKRecord()
                    if self.newPencil {
                        if let product = self.product {
                            pencilRecord.assignParentReference(parentRecord: product.toCKRecord(), relationshipName: PencilRelationships.product.rawValue)
                        }
                    }
                    let userInfo = [AppNotificationInfoKeys.DidEditPencilPencilKey.rawValue : self.pencil]
                    NSNotificationCenter.defaultCenter().postNotificationName(AppNotifications.DidEditPencil.rawValue, object: nil, userInfo: userInfo)                    
                    self.cloudStoreRecords([pencilRecord])
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
        self.showHUD(header: nil, footer: nil)
        CloudManager.sharedManger.syncChangeSet(records){ [unowned self] (success, returnedRecords, error) -> Void in
            self.hideHUD()
            self.saveButton.enabled = true
            assert(success, error!.localizedDescription)
            self.context.performBlock({(_) in
                if let results = returnedRecords {
                    if let rec = results.first {
                        self.pencil.populateFromCKRecord(rec)
                    }
                }
                return .SaveToPersistentStore
            }, completionHandler: { [unowned self] (result: Result<CommitAction>) in
                if self.newPencil {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.toggleEditing(false)
                    self.navigationItem.leftBarButtonItem = nil
                    self.navigationItem.rightBarButtonItem = self.editButton
                }
            })
        }
    }
    
    // MARK: inventory management methods
    
    
    private func addPencilToInventory() {
        self.context.performBlock({ [unowned self] (context: NSManagedObjectContext) in
            let inventory = Inventory(managedObjectContext: self.context)
            inventory.populateWithPencil(self.pencil)
            return .SaveToPersistentStore
        },
        completionHandler: { [unowned self] (result: Result<CommitAction>) in
            
            switch result {
            case let .Failure(error):
                assertionFailure("Unable to save inventory: \(error)")
            default:
                var userInfo = [AppNotificationInfoKeys.DidEditPencilPencilKey.rawValue : self.pencil ]
                NSNotificationCenter.defaultCenter().postNotificationName(AppNotifications.DidEditPencil.rawValue, object: nil, userInfo: userInfo)
            }
            
        })
    }
    
}

// MARK: - Table view data source
extension EditPencilTableViewController: UITableViewDataSource {
    
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
            var cell = tableView.dequeueReusableCellWithIdentifier(EditPecilPropertyTableViewCell.nibName, forIndexPath: indexPath) as EditPecilPropertyTableViewCell
            cell.pencil = self.pencil
            if indexPath.row == 0 {
                cell.placeholder = NSLocalizedString("Color Name", comment:"edit pencil color name placeholder")
                cell.keyPath = "name"
            } else {
                cell.placeholder = NSLocalizedString("Color Code e.g. PC1097", comment:"edit pencil color code placeholder")
                cell.keyPath = "identifier"
            }
            return cell
        } else if indexPath.section == 1 {
            if !self.tableView.editing {
                var cell = tableView.dequeueReusableCellWithIdentifier(PencilColorTableViewCell.nibName, forIndexPath: indexPath) as PencilColorTableViewCell
                let color = self.pencil.color as? UIColor ?? UIColor.blackColor()
                cell.swatchColor = color
                cell.colorName = color.hexRepresentation
                return cell
            }
            var cell = tableView.dequeueReusableCellWithIdentifier(PencilColorPickerTableViewCell.nibName, forIndexPath: indexPath) as PencilColorPickerTableViewCell
            cell.defaultColor = self.pencil.color as UIColor? ?? UIColor.blackColor()
            cell.delegate = self
            return cell
        } else {
            var title = (self.pencil.inventory != nil) ? NSLocalizedString("You own this pencil.", comment:"edit pencil button title") : NSLocalizedString("Add Pencil To My Inventory", comment:"edit pencil add pencil to inventory button title")
            var cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName) as BigButtonTableViewCell
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
    
}

// MARK: - Table view delegate
extension EditPencilTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.tableView.editing {
            if indexPath.section == 0 {
                return 50.0
            } else {
                return 159.0
            }
        }
        return 44.0
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
        let cell = tableView.cellForRowAtIndexPath(indexPath) as BigButtonTableViewCell
        if !cell.disabled {
            self.addPencilToInventory()
            cell.title = NSLocalizedString("You own this pencil.", comment:"edit pencil button title")
            cell.disabled = true
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

    
    
}

extension EditPencilTableViewController: PencilColorPickerTableViewCellDelegate {
    
    func colorPickerTableViewCell(cell: PencilColorPickerTableViewCell, didChangeColor color: UIColor) {
        self.pencil.color = color
    }
    
}

