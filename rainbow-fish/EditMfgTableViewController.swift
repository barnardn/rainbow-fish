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

    fileprivate var allManufacturers = [Manufacturer]()
    
    fileprivate lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditMfgTableViewController.doneButtonTapped(_:)))
        return button
    }()
    
    convenience init() {
        self.init(style: UITableViewStyle.grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: DefaultTableViewCell.nibName as String)
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.updateDatasource()
    }

    fileprivate func updateDatasource() {
        
        let results = try? CDK.mainThreadContext.find(Manufacturer.self, predicate: nil, sortDescriptors: [NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)], limit: nil, offset: nil)
        self.allManufacturers = results ?? [Manufacturer]()
        self.tableView!.reloadData()
    }
    
    func doneButtonTapped(_ sender: UIBarButtonItem) {
        let viewController = CatalogViewController()
        self.navigationController?.setViewControllers([viewController], animated: true)
    }
    
    func isOwnedByMe(_ object: CloudSyncable) -> Bool {
        return (object.ownerRecordIdentifier == AppController.appController.appConfiguration.iCloudRecordID)
    }
    
    func editManufacturer(_ mfg: Manufacturer) {
        let viewController = EditManufacturerNavigationController(manufacturer: mfg) { (didSave, edittedText, sender) -> Void in
            if !didSave {
                self.dismiss(animated: true, completion: nil)
                return;
            }
            sender?.isEnabled = false
            mfg.managedObjectContext?.perform(block: { (context: NSManagedObjectContext) in
                mfg.name = edittedText
                return CommitAction.saveToPersistentStore
            }, completionHandler: { (result) in
                sender?.isEnabled = true
                do {
                    let _ = try result()
                    self.syncEditsToCloud(mfg, completion: { [unowned self] () -> Void in
                        self.dismiss(animated: true, completion: nil)
                        self.tableView.reloadData()
                    })
                } catch {
                    assertionFailure()
                }
            })
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    func editProduct(_ product: Product) {
        let viewController = EditProductNavigationController(product: product) { (didSave, edittedText, sender) -> Void in
            if !didSave {
                self.dismiss(animated: true, completion: nil)
                return;
            }
            sender?.isEnabled = false
            product.managedObjectContext?.perform(block: { (context: NSManagedObjectContext) in
                product.name = edittedText
                return CommitAction.saveToPersistentStore
                }, completionHandler: { (result) in
                    sender?.isEnabled = true
                    do {
                        let _ = try result()
                        self.syncEditsToCloud(product) { [unowned self] in
                            self.dismiss(animated: true, completion: nil)
                            self.tableView.reloadData()
                        }
                    } catch {
                        assertionFailure()
                    }
                })
        }
        self.present(viewController, animated: true, completion: nil)

    }
    
    func syncEditsToCloud(_ cloudObject: CloudSyncable, completion: @escaping () -> Void) {
        let record = cloudObject.toCKRecord()
        self.showHUD()
        CloudManager.sharedManger.syncChangeSet([record], completion: { [unowned self] (success, savedRecords, error) -> Void in
            self.hideHUD()
            DispatchQueue.main.async { completion() }
        })
    }

    //MARK: tableview datasource
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.allManufacturers.count;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mfg = self.allManufacturers[section]
        return mfg.products.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DefaultTableViewCell.nibName as String, for: indexPath) as! DefaultTableViewCell
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cloudObject = self.cloudObjectAt(indexPath)
        if let mfg = cloudObject as? Manufacturer, indexPath.row == 0 {
            self.editManufacturer(mfg)
        } else if let product = cloudObject as? Product, indexPath.row > 0 {
            self.editProduct(product)
        }
    
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cloudObject = self.cloudObjectAt(indexPath)
        if self.isOwnedByMe(cloudObject) {
            cell.textLabel?.textColor = AppearanceManager.appearanceManager.blackColor
            cell.selectionStyle = .blue
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.textColor = AppearanceManager.appearanceManager.disabledTitleColor
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cloudObject = self.cloudObjectAt(indexPath)
        return self.isOwnedByMe(cloudObject) ? indexPath : nil
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return (indexPath.row == 0) ? 0 : 1;
    }
    
    fileprivate func cloudObjectAt(_ indexPath: IndexPath) -> CloudSyncable {
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
