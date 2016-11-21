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
        case details, color, quantity, delete
    }
    
    enum InventoryRow: Int {
        case manufacturer, product, colorName, color, quantity, delete
    }
    
    let sectionInfo: [[InventoryRow]] = [[.manufacturer, .product, .colorName],
                                         [.color], [.quantity], [.delete]]
    
    fileprivate var context: NSManagedObjectContext!
    fileprivate var lineItem: Inventory!
    fileprivate var editPencilColor: Bool = false
    
    fileprivate lazy var doneBarButtonItem: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InventoryDetailTableViewController.doneButtonTapped(_:)))
        return doneButton
    }()
    
    var itemUpdatedBlock: ((_ lineItemWithIdentity: NSManagedObjectID, _ wasDeleted: Bool) -> Void)?
    
    convenience init(lineItem: Inventory) {
        self.init(style: UITableViewStyle.grouped)
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, parentContext: CDK.mainThreadContext)
        self.context.undoManager = nil
        self.lineItem = self.context.object(with: lineItem.objectID) as? Inventory
        self.title = self.lineItem.name
        
        NotificationCenter.default.addObserver(self, selector: #selector(InventoryDetailTableViewController.contextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.context)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = CGFloat(44.0)
        self.tableView.register(UINib(nibName: DefaultTableViewCell.nibName as String, bundle: nil), forCellReuseIdentifier: DefaultTableViewCell.nibName as String)
        self.tableView.register(UINib(nibName: DefaultDetailTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultDetailTableViewCell.nibName)
        self.tableView.register(UINib(nibName: InventoryQuantityTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: InventoryQuantityTableViewCell.nibName)
        self.tableView.register(UINib(nibName: PencilColorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorTableViewCell.nibName)
        self.tableView.register(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        self.tableView.register(UINib(nibName: PencilColorPickerTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorPickerTableViewCell.nibName)
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if self.context.hasChanges && parent == nil {
            self.saveChanges()
        }
        
    }
    
    // MARK: context notification handler
    
    
    func contextDidSave(_ notification: Notification) {
        
        if  let userInfo = notification.userInfo,
            let itemSet = userInfo[NSDeletedObjectsKey] as? NSSet,
            let block = self.itemUpdatedBlock, itemSet.count > 0 {
                block(self.lineItem.objectID, true)
        }        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: private api
    
    fileprivate func saveChanges() {
        self.context.perform( block: {(ctx: NSManagedObjectContext) in
            return .saveToPersistentStore
            }, completionHandler: {[unowned self] (result) in
                do {
                    let _ = try result()
                    if let block = self.itemUpdatedBlock {
                        
                        DispatchQueue.main.async {
                            block(self.lineItem.objectID, false)
                        }

                    }
                } catch {
                    assertionFailure()
                }
            })
    }
    
    @objc fileprivate func doneButtonTapped(_ sender: UIBarButtonItem) {
        let _ = self.navigationController?.popViewController(animated: true);
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionInfo.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDetail = self.sectionInfo[section]
        return sectionDetail.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch (indexPath.section, indexPath.row) {
        case (0,0...1):
            let cell = tableView.dequeueReusableCell(withIdentifier: DefaultTableViewCell.nibName as String, for: indexPath) as! DefaultTableViewCell
            configureDetailCell(cell, atIndexPath: indexPath)
            return cell
        case (0, 2):
            let cell = tableView.dequeueReusableCell(withIdentifier: DefaultDetailTableViewCell.nibName, for: indexPath) as! DefaultDetailTableViewCell
            cell.textLabel?.text = self.lineItem.name
            cell.detailTextLabel?.text = self.lineItem.pencilIdentifier
            cell.selectionStyle = .none
            return cell
        case (1, _):
            if self.editPencilColor {
                let cell = tableView.dequeueReusableCell(withIdentifier: PencilColorPickerTableViewCell.nibName, for: indexPath) as! PencilColorPickerTableViewCell
                self.configureColorPickerCell(cell, atIndexPath: indexPath)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: PencilColorTableViewCell.nibName, for: indexPath) as! PencilColorTableViewCell
            configureColorSwatchCell(cell, atIndexPath: indexPath)
            return cell
        case (2, _) :
            let cell = tableView.dequeueReusableCell(withIdentifier: InventoryQuantityTableViewCell.nibName, for: indexPath) as! InventoryQuantityTableViewCell
            configureQuantityCell(cell, atIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: BigButtonTableViewCell.nibName, for: indexPath) as! BigButtonTableViewCell
            configureButtonCell(cell, atIndexPath: indexPath)
            return cell
        }
        
    }
    
    fileprivate func configureDetailCell(_ cell: DefaultTableViewCell, atIndexPath indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.textLabel?.text = self.lineItem.manufacturerName
        } else {
            cell.textLabel?.text = self.lineItem.productName
        }
        cell.selectionStyle = .none
    }
    
    fileprivate func configureColorSwatchCell(_ cell: PencilColorTableViewCell, atIndexPath indexPath: IndexPath) {
        if let color = self.lineItem.color as? UIColor {
            cell.colorName = color.hexRepresentation
            cell.swatchColor = color
        } else {
            cell.colorName = nil
            cell.swatchColor = nil
        }
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
    }
    
    fileprivate func configureColorPickerCell(_ cell: PencilColorPickerTableViewCell, atIndexPath indexPath: IndexPath) {
        cell.defaultColor = self.lineItem.color as! UIColor? ?? UIColor.black
        cell.delegate = self
    }
    
    fileprivate func configureQuantityCell(_ cell: InventoryQuantityTableViewCell, atIndexPath indexPath: IndexPath ) {
        cell.lineItem = self.lineItem        
    }
    
    
    fileprivate func configureButtonCell(_ cell: BigButtonTableViewCell, atIndexPath indexPath: IndexPath) {
        cell.destructiveButton = true
        cell.title = NSLocalizedString("Remove From My Inventory", comment:"remove pencil from inventory button title")
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == InventorySection.color.rawValue {
            self.editPencilColor = !self.editPencilColor // ? false : true
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            return
        }

        if indexPath.section != InventorySection.delete.rawValue {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        let pencilName = self.lineItem.name!
        let confirmController = UIAlertController(title: NSLocalizedString("Remove From Inventory", comment:"confirm pencil inventory item alert title"), message: NSLocalizedString("Are you sure you want to remove \"\(pencilName)\" from your inventory?", comment:"confirm pencil deletion message"), preferredStyle: .alert)
        
        confirmController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        confirmController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { [unowned self] (_: UIAlertAction!) -> Void in
            self.context.perform(block: {(context: NSManagedObjectContext) in
                
                context.delete(self.lineItem)
                
                return .saveToPersistentStore
                }, completionHandler: {(result) in
                    do {
                        let _ = try result()
                    } catch {
                        assertionFailure()
                    }
            })
        }))
        self.present(confirmController, animated: true, completion: nil);
        confirmController.view.tintColor = AppearanceManager.appearanceManager.brandColor
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 46.0
        } else if indexPath.section == InventorySection.color.rawValue && self.editPencilColor {
            return PencilColorPickerTableViewCell.preferredRowHeight
        }
        return 44.0
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case InventorySection.details.rawValue:
            return NSLocalizedString("Pencil Details", comment:"inventory details  header title")
        case InventorySection.color.rawValue:
            return NSLocalizedString("Adjust Color", comment:"inventory details color header title")
        case InventorySection.quantity.rawValue:
            return NSLocalizedString("Quantity On Hand", comment:"inventory details quantity header title")
        default:
            return nil
        }
    }
    
}

extension InventoryDetailTableViewController: PencilColorPickerTableViewCellDelegate, UITextFieldDelegate {
    
    func colorPickerTableViewCell(_ cell: PencilColorPickerTableViewCell, didChangeColor color: UIColor) {
        self.lineItem.color = color
    }
    
    func colorPickerTableViewCell(_ cell: PencilColorPickerTableViewCell, didRequestHexCodeWithColor color: UIColor?) {
        
        var hexTextField: UITextField?
        
        let alertController = UIAlertController(title: NSLocalizedString("Enter Hex Code", comment:"hex alert title"), message: NSLocalizedString("Enter the color code in hexadecimal e.g. \"0A41CD\"", comment:"hex alert message"), preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"ok button title"), style: .default) { [unowned self] (_) -> Void in
            if  let hexStr = hexTextField?.text,
                let color = UIColor.colorFromHexString(hexStr) {
                    self.lineItem.color = color
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
        if (textField.text?.characters.count)! + string.characters.count > 6 {
            return false
        }
        let nonHexChars = CharacterSet(charactersIn: "0123456789ABCDEFabcdef").inverted
        if let _ = string.rangeOfCharacter(from: nonHexChars, options: NSString.CompareOptions.caseInsensitive) {
            return false
        }
        return true
    }
    
    
}
