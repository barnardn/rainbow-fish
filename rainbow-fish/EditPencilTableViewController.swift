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

    fileprivate var pencil: Pencil!
    fileprivate var context: NSManagedObjectContext!
    fileprivate var newPencil: Bool = false
    fileprivate var product: Product?
    fileprivate var editPenilKVOContext = 0
    fileprivate var recordCreatorID : String? = ""       // thread safety!
    
    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(EditPencilTableViewController.saveButonTapped(_:)))
        return button
    }()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(EditPencilTableViewController.editButtonTapped(_:)))
        return button
    }()

    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(EditPencilTableViewController.cancelButtonTapped(_:)))
        return button
    }()
    
    convenience init(pencil: Pencil?) {
        self.init(style: UITableViewStyle.grouped)
        self.recordCreatorID = AppController.appController.appConfiguration.iCloudRecordID
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, parentContext: CDK.mainThreadContext)
        if let editPencil = pencil {
            self.title = editPencil.name ?? NSLocalizedString("Edit Pencil", comment:"edit an existing pencil view title")
            self.pencil = self.context.object(with: editPencil.objectID) as! Pencil
            NotificationCenter.default.addObserver(self, selector: #selector(EditPencilTableViewController.inventoryDeletedNotificationHandler(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
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
        self.pencil.product = self.context.object(with: self.product!.objectID) as? Product
    }
    
    deinit {
        self.observePencilChanges(false)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        self.tableView.register(UINib(nibName: EditPecilPropertyTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: EditPecilPropertyTableViewCell.nibName)
        self.tableView.register(UINib(nibName: PencilColorPickerTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorPickerTableViewCell.nibName)
        self.tableView.register(UINib(nibName: PencilColorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorTableViewCell.nibName)
        self.tableView.register(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        if self.pencil.isMyPencil() && AppController.appController.isNormsiPhone() {
            self.navigationItem.rightBarButtonItem = self.editButton
        }
        if self.newPencil {
            self.navigationItem.leftBarButtonItem = self.cancelButton
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.isEditing = true
        }
        self.observePencilChanges(true)
    }
    
    // MARK: kvo notification handler
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context != &editPenilKVOContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if !self.tableView.isEditing {
            return
        }
        if self.pencil.canSave() {
            self.navigationItem.setRightBarButton(self.saveButton, animated: true)
        } else {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    fileprivate func observePencilChanges(_ observe: Bool) {
        if observe {
            self.pencil.addObserver(self, forKeyPath: PencilAttributes.name.rawValue, options: .new, context: &editPenilKVOContext)
            self.pencil.addObserver(self, forKeyPath: PencilAttributes.identifier.rawValue, options: .new, context: &editPenilKVOContext)
        } else {
            self.pencil.removeObserver(self, forKeyPath: PencilAttributes.name.rawValue, context: &editPenilKVOContext)
            self.pencil.removeObserver(self, forKeyPath: PencilAttributes.identifier.rawValue, context: &editPenilKVOContext)
        }
    }
    
    // MARK: managedObjectContext changed notification handler
    
    func inventoryDeletedNotificationHandler(_ notification: Notification) {
        if let deletedSet = notification.userInfo?[NSDeletedObjectsKey] as? NSSet,
            let deletedObjects = deletedSet.allObjects as? [NSManagedObject]  {
            let matching = deletedObjects.filter{ $0.objectID == self.pencil.inventory?.objectID }
            if matching.count > 0 {
                self.context.mergeChanges(fromContextDidSave: notification)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: button actions
    
    func editButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationItem.setRightBarButton(self.saveButton, animated: true)
        self.navigationItem.setLeftBarButton(self.cancelButton, animated: true)
        self.toggleEditing(true)
    }

    func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if self.newPencil {
            self.tableView.endEditing(true)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            return
        }
        self.observePencilChanges(false)
        self.navigationItem.setRightBarButton(self.editButton, animated: true)
        self.navigationItem.setLeftBarButton(nil, animated: true)
        self.context.rollback()
        self.pencil = self.context.object(with: self.pencil.objectID) as! Pencil
        self.toggleEditing(false)
        self.observePencilChanges(true)
    }
    
    func saveButonTapped(_ sender: UIBarButtonItem) {
        
        self.tableView.endEditing(true)
        sender.isEnabled = false
        self.context.perform(
            block: { [unowned self] (_) in
                if let lineItem = self.pencil.inventory {
                    lineItem.populateWithPencil(self.pencil)
                }
                return .saveToPersistentStore
            }, completionHandler: {[unowned self] (result) in
                do {
                    let _ = try result()
                    let pencilRecord = self.pencil.toCKRecord()
                    if self.newPencil {
                        if let product = self.product {
                            pencilRecord.assignParentReference(parentRecord: product.toCKRecord(), relationshipName: PencilRelationships.product.rawValue)
                        }
                    }
                    let userInfo = [AppNotificationInfoKeys.DidEditPencilPencilKey.rawValue : self.pencil]

                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(AppNotifications.DidEditPencil.rawValue), object: nil, userInfo: userInfo)
                    }
                    
                    self.cloudStoreRecords([pencilRecord])
                } catch {
                    assertionFailure()
                }
        })
    }
    
    fileprivate func toggleEditing(_ editing: Bool) {
        self.tableView.beginUpdates()
        self.tableView.setEditing(editing, animated: true)
        if editing {
            self.tableView.deleteSections(IndexSet(integer: 2), with: .automatic)
        } else {
            self.tableView.insertSections(IndexSet(integer: 2), with: .automatic)
        }
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        self.tableView.endUpdates()
    }
    
    fileprivate func cloudStoreRecords(_ records: [CKRecord]) {
        self.showHUD()
        CloudManager.sharedManger.syncChangeSet(records){ [unowned self] (success, returnedRecords, error) -> Void in
            self.hideHUD()
            self.saveButton.isEnabled = true
            if !success {
                print(error!.localizedDescription)
                print(error!.userInfo)
                assertionFailure("bummer: \(error!.localizedDescription)")
            }
            self.context.perform(block: { [unowned self] (_) in
                if let results = returnedRecords {
                    if let rec = results.first {
                        self.pencil.populateFromCKRecord(rec)
                    }
                }
                return .saveToPersistentStore
            }, completionHandler: { [unowned self] (result) in
                
                do {
                    let _ = try result()
                    
                    DispatchQueue.main.async { [unowned self] in
                        if self.newPencil {
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        } else {
                            self.toggleEditing(false)
                            self.navigationItem.leftBarButtonItem = nil
                            self.navigationItem.rightBarButtonItem = self.editButton
                        }
                    }

                } catch {
                    assertionFailure()
                }
            })
        }
    }
    
    // MARK: inventory management methods
    
    
    fileprivate func addPencilToInventory() {
        
        self.context.perform(block: { [unowned self] (context: NSManagedObjectContext) in
                let inventory = Inventory(managedObjectContext: context)!
                let pencil = context.object(with: self.pencil.objectID) as! Pencil
                inventory.populateWithPencil(pencil)
                return .saveToPersistentStore
            },
            completionHandler: { [unowned self] (result) in
                
                do {
                    let _ = try result()
                    let userInfo = [AppNotificationInfoKeys.DidEditPencilPencilKey.rawValue : self.pencil.objectID ]
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(AppNotifications.DidEditPencil.rawValue), object: nil, userInfo: userInfo)
                    }
                } catch {
                    assertionFailure()
                }
            })
    }
    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.newPencil {
            return 2
        }
        return (self.tableView.isEditing) ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EditPecilPropertyTableViewCell.nibName, for: indexPath) as! EditPecilPropertyTableViewCell
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
            if !self.tableView.isEditing {
                let cell = tableView.dequeueReusableCell(withIdentifier: PencilColorTableViewCell.nibName, for: indexPath) as! PencilColorTableViewCell
                let color = self.pencil.color as? UIColor ?? UIColor.black
                cell.swatchColor = color
                cell.colorName = color.hexRepresentation
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: PencilColorPickerTableViewCell.nibName, for: indexPath) as! PencilColorPickerTableViewCell
            cell.defaultColor = self.pencil.color as! UIColor? ?? UIColor.black
            cell.delegate = self
            return cell
        } else {
            let title = (self.pencil.inventory != nil) ? NSLocalizedString("You own this pencil.", comment:"edit pencil button title") : NSLocalizedString("Add Pencil To My Inventory", comment:"edit pencil add pencil to inventory button title")
            let cell = tableView.dequeueReusableCell(withIdentifier: BigButtonTableViewCell.nibName) as! BigButtonTableViewCell
            cell.title = title
            cell.disabled = (self.pencil.inventory != nil)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.tableView.isEditing {
            return (indexPath.section != 1)
        }
        return false
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.tableView.isEditing {
            if indexPath.section == 0 {
                return 50.0
            } else {
                return PencilColorPickerTableViewCell.preferredRowHeight
            }
        }
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.tableView.isEditing && self.pencil.name == nil {
            if indexPath.section == 0 && indexPath.row == 0 {
                cell.becomeFirstResponder()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 2 {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as! BigButtonTableViewCell
        if !cell.disabled {
            self.addPencilToInventory()
            cell.title = NSLocalizedString("You own this pencil.", comment:"edit pencil button title")
            cell.disabled = true
            delay(0.33){ () -> Void in
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension EditPencilTableViewController: PencilColorPickerTableViewCellDelegate, UITextFieldDelegate {
    
    func colorPickerTableViewCell(_ cell: PencilColorPickerTableViewCell, didChangeColor color: UIColor) {
        self.pencil.color = color
    }
    
    func colorPickerTableViewCell(_ cell: PencilColorPickerTableViewCell, didRequestHexCodeWithColor color: UIColor?) {
        
        var hexTextField: UITextField?
        
        let alertController = UIAlertController(title: NSLocalizedString("Enter Hex Code", comment:"hex alert title"), message: NSLocalizedString("Enter the color code in hexadecimal e.g. \"0A41CD\"", comment:"hex alert message"), preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"ok button title"), style: .default) { [unowned self] (_) -> Void in
            if  let hexStr = hexTextField?.text,
                let color = UIColor.colorFromHexString(hexStr) {
                self.pencil.color = color
                self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
            }
        })

        alertController.addTextField { [unowned self] (textField) -> Void in
            hexTextField = textField
            hexTextField?.textAlignment = .center
            hexTextField?.delegate = self
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"cancel button title"), style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 {
            return true
        }
        if textField.text!.characters.count + string.characters.count > 6 {
            return false
        }
        let nonHexChars = CharacterSet(charactersIn: "0123456789ABCDEFabcdef").inverted
        if let _ = string.rangeOfCharacter(from: nonHexChars, options: NSString.CompareOptions.caseInsensitive) {
            return false
        }
        return true
    }
    
    
}

