//
//  SettingsTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CoreData
import CoreDataKit
import UIKit

class SettingsTableViewController: ContentTableViewController {

    enum Sections: Int {
        case MinimumInventory
        case DataManagement
    }
    
    enum InventoryRows: Int {
        case MinimumInventory
    }
    
    enum DataManagementRows: Int {
        case DataExport
        case DataImport
    }
    
    private var settingsContext = 0
    private var allowDataImportSection = false
    
    private lazy var cloudImporter: CloudImport = {
        return CloudImport()
    }()
    
    let sectionInfo = [ [InventoryRows.MinimumInventory.rawValue], [DataManagementRows.DataExport.rawValue, DataManagementRows.DataImport.rawValue] ]
    
    convenience init() {
        self.init(style: .Grouped)
        let image = UIImage(named: "tabbar-icon-settings")?.imageWithRenderingMode(.AlwaysTemplate)
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment:"setting tabbar item title"), image: image, tag: 0)
        self.title = NSLocalizedString("Settings", comment:"setting tabbar item title")
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "minInventoryQuantity", context: &settingsContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        
        self.tableView.registerClass(ProductHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProductHeaderView")
        AppController.appController.appConfiguration.addObserver(self, forKeyPath: "minInventoryQuantity", options: .New, context: &settingsContext)
        if let ownerCloudId = AppController.appController.appConfiguration.iCloudRecordID {
            println("cloud \(ownerCloudId)")
            let checkKey = ownerCloudId.sha1()
            println("check \(checkKey)")
            if checkKey == AppController.appController.dataImportKey {
                allowDataImportSection = true
            }
        }
    }
    
    // MARK: kvo 
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &settingsContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        if keyPath == "minInventoryQuantity" {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: Sections.MinimumInventory.rawValue)], withRowAnimation: .None)
        }
    }
    
    // MARK: methods
    
    func exportDatabase (completionHandler: (success: Bool, error: NSError?) -> Void ){
        CDK.performBlockOnBackgroundContext({ (context: NSManagedObjectContext) in
            let results = context.find(Manufacturer.self)
            if let dbError = results.error() {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(success: false, error: dbError) }
                return .DoNothing
            } else {
                if let allMfg = results.value() {
                    var database = NSMutableArray(capacity: allMfg.count)
                    for mfg in allMfg {
                        database.addObject(mfg.toJson(includeRelationships: true))
                    }
                    let outUrl = AppController.appController.urlForResourceInApplicationSupport(resourceName: "database.json")
                    var jsonError: NSError?
                    let obj = NSJSONSerialization.dataWithJSONObject(database, options: .PrettyPrinted, error: &jsonError) as NSData?
                    if let jsonError = jsonError {
                        dispatch_async(dispatch_get_main_queue()) { completionHandler(success: false, error: jsonError) }
                    } else {
                        obj!.writeToURL(outUrl, atomically: true)
                        dispatch_async(dispatch_get_main_queue()) { completionHandler(success: true, error: nil) }
                    }
                }
            }
            return CommitAction.DoNothing
            }, completionHandler: nil)
        
    }
    
    func seedCloudDatabase() {
        
        // check existence of "database.json"
        
        self.showHUD(header: "Seeding Cloud", footer: nil)
        self.cloudImporter.seedToCloud({ (success, error) -> Void in
            self.hideHUD()
            if let err = error {
                assertionFailure(err.localizedDescription)
            } else {
                println("Yay")
            }
        })
    }
    
}


extension SettingsTableViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.allowDataImportSection) ? self.sectionInfo.count : self.sectionInfo.count - 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let thisSection = self.sectionInfo[section]
        return thisSection.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let ixPath = (indexPath.section, indexPath.row)
        switch ixPath {
        case (Sections.DataManagement.rawValue, 0):
            return self.configureDataExportCell(indexPath)
        case  (Sections.DataManagement.rawValue, 1):
            return self.configureDataImportCell(indexPath)
            
        default:
            return self.configureInventoryCell(indexPath)
        }
    }
    
    private func configureInventoryCell(indexPath: NSIndexPath) -> NameValueTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NameValueTableViewCell.nibName, forIndexPath: indexPath) as NameValueTableViewCell
        cell.name = NSLocalizedString("Minimum Inventory", comment:"settings pencil remaining title")
        if let quantity = AppController.appController.appConfiguration.minInventoryQuantity {
            cell.value = formatDecimalQuantity(quantity)
        } else {
            cell.value = "0"
        }
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    private func configureDataImportCell(indexPath: NSIndexPath) -> BigButtonTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as BigButtonTableViewCell
        cell.title = NSLocalizedString("Seed Database", comment:"seed database admin function")
        return cell
    }
    
    private func configureDataExportCell(indexPath: NSIndexPath) -> BigButtonTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as BigButtonTableViewCell
        cell.title = NSLocalizedString("Export Database", comment:"export database admin function")
        return cell
    }
    
    private func formatDecimalQuantity(quantity: NSDecimalNumber) -> String {
        let wholeNumber = Int(floorf(quantity.floatValue))
        if fmodf(quantity.floatValue, 1.0) > 0 {
            if wholeNumber == 0 {
                return "½"
            } else {
                return "\(wholeNumber)½"
            }
        }
        return "\(wholeNumber)"
    }

}

extension SettingsTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController: UIViewController?
        
        let ixPath = (indexPath.section, indexPath.row)
        
        switch ixPath {
        case (Sections.DataManagement.rawValue, DataManagementRows.DataExport.rawValue):
            self.showHUD(header: "Creating Export", footer: nil)
            self.exportDatabase({ (success, error) -> Void in
                self.hideHUD()
                if let e = error {
                    assertionFailure(e.localizedDescription)
                }
            })
        case (Sections.DataManagement.rawValue, DataManagementRows.DataImport.rawValue):
            self.seedCloudDatabase()
        default:
            viewController = SettingsMinimumStockTableViewController()
        }
        
        if let viewController = viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProductHeaderView") as ProductHeaderView
        let title = (section == Sections.MinimumInventory.rawValue) ? NSLocalizedString("Inventory Management", comment:"settings inventory mananagement section header") : "Data Management"
        headerView.title = title
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductHeaderView.headerHeight
    }
    
}

