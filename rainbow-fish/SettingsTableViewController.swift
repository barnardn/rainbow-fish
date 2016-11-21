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
        case minimumInventory
        case appPurchase
        case dataManagement
    }
    
    enum InventoryRows: Int {
        case minimumInventory
    }
    
    enum AppPurchaseRows: Int {
        case inAppPurchaseRow
    }
    
    enum DataManagementRows: Int {
        case dataExport
        case dataImport
        case dataSeed
    }
    
    fileprivate var settingsContext = 0
    fileprivate var allowDataImportSection = false
    
    fileprivate lazy var cloudImporter: CloudImport = {
        return CloudImport()
    }()
    
    fileprivate lazy var catalogSeeder: Seeder = {
        return Seeder()
    }()
    
    var sectionInfo = [ [InventoryRows.minimumInventory.rawValue], [AppPurchaseRows.inAppPurchaseRow.rawValue], [DataManagementRows.dataExport.rawValue, DataManagementRows.dataImport.rawValue] ]
    
    convenience init() {
        self.init(style: .grouped)
        let image = UIImage(named: "tabbar-icon-settings")?.withRenderingMode(.alwaysTemplate)
        self.title = NSLocalizedString("Settings", comment:"setting navigation item title")
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment:"setting tabbar item title"), image: image, tag: 0)
        
    
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "minInventoryQuantity", context: &settingsContext)
        self.removeObserver(self, forKeyPath: "purchaseStatus", context: &settingsContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        self.tableView.register(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        
        self.tableView.register(ProductHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProductHeaderView")
        
        AppController.appController.appConfiguration.addObserver(self, forKeyPath: "minInventoryQuantity", options: .new, context: &settingsContext)
        AppController.appController.appConfiguration.addObserver(self, forKeyPath: "purchaseStatus", options: .new, context: &settingsContext)
        
        if AppController.appController.isNormsiPhone() {
            allowDataImportSection = true
        }
        
        if AppController.appController.isNormsiPhone() {
            var _ = self.sectionInfo.removeLast()
            self.sectionInfo.append([DataManagementRows.dataExport.rawValue, DataManagementRows.dataImport.rawValue, DataManagementRows.dataSeed.rawValue])
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !AppController.appController.allowsAppIconBadge() {
            let settings = UIUserNotificationSettings(types: .badge, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    

    // MARK: kvo 
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &settingsContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        switch keyPath! {
            case "minInventoryQuantity":
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: Sections.minimumInventory.rawValue)], with: .none)
            case "purchaseStatus":
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: Sections.appPurchase.rawValue)], with: .none)
            default:
                assertionFailure("unknown keypath observed \(keyPath)")
        }
    }
    
    // MARK: methods
    
    fileprivate func exportDatabase (_ completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void ) throws {
        CDK.performOnBackgroundContext(block: { (context: NSManagedObjectContext) in

            do {
                let results = try context.find(Manufacturer.self)
                let database = NSMutableArray(capacity: results.count)
                for mfg in results {
                    database.add(mfg.toJson(true))
                }
                let outUrl = AppController.appController.urlForResourceInApplicationSupport(resourceName: "database.json")
                if let obj = try? JSONSerialization.data(withJSONObject: database, options: .prettyPrinted) {
                    try! obj.write(to: outUrl, options: .atomicWrite)
                    DispatchQueue.main.async { completionHandler(true, nil) }
                }
                
            } catch CoreDataKitError.coreDataError(let coreDataError) {
                let nserror = NSError(domain: "com.clamdango.rainbowfish", code: 100, userInfo: [NSLocalizedDescriptionKey : "\(coreDataError)"])
                completionHandler(false, nserror)
                
            } catch {
                completionHandler(false, nil)
            }
            
            return CommitAction.doNothing
            
            }, completionHandler: nil)
        
    }
    
    fileprivate func seedCloudDatabase() {
        
        // check existence of "database.json"
        
        self.showHUD(message:"Seeding Cloud")
        self.cloudImporter.seedToCloud({ (success, error) -> Void in
            self.hideHUD()
            if let err = error {
                assertionFailure(err.localizedDescription)
            } else {
                print("Yay")
            }
        })
    }
    
    fileprivate func confirmCreateDatabase() {
        let alert = UIAlertController(title: "Confirm Action", message: "This operation will *INSERT* rows into the current public cloud database. Are you REALLY sure you want to do this?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Go!", style: .default, handler: { [unowned self] (_) -> Void in
            self.createDatabaseFromSeedJson()
            }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
    
    fileprivate func createDatabaseFromSeedJson() {

        guard let results = try? CDK.mainThreadContext.find(Manufacturer.self), results.count == 0 else {
            
            let alert = UIAlertController(title: "Records Found", message: "There are existing records in your local store. This operation can only be safely completed on an empty local and remote store.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            alert.view.tintColor = AppearanceManager.appearanceManager.brandColor
            
            return
            
        }
        
        do {
            
            self.showHUD(message: "Creating Catalog...")
            try self.catalogSeeder.createCloudkitCatalog({ [unowned self] (success, message) -> Void in
                    self.showHUD(message: message)
                    print(message!)
                },
                completion: { [unowned self] (success, message) -> Void in
                    self.hideHUD()
            })
            
        } catch SeedError.error(let message) {
            
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            
            self.present(alert, animated: true) { [unowned self] in
                self.hideHUD()
            }
        } catch {
            assertionFailure("Unknown exception!(?)")
        }
        
    }
    
    
    
    //MARK: tableview data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (self.allowDataImportSection) ? self.sectionInfo.count : self.sectionInfo.count - 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let thisSection = self.sectionInfo[section]
        return thisSection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ixPath = (indexPath.section, indexPath.row)
        switch ixPath {
        case (Sections.dataManagement.rawValue, 0):
            return self.configureDataExportCell(indexPath)
        case  (Sections.dataManagement.rawValue, 1):
            return self.configureDataImportCell(indexPath)
        case (Sections.dataManagement.rawValue, DataManagementRows.dataSeed.rawValue):
            return self.configureSeedSell(indexPath)
        case (Sections.appPurchase.rawValue, AppPurchaseRows.inAppPurchaseRow.rawValue):
            return self.configureInAppPurchaseCell(indexPath)
        default:
            return self.configureInventoryCell(indexPath)
        }
    }
    
    fileprivate func configureInventoryCell(_ indexPath: IndexPath) -> NameValueTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NameValueTableViewCell.nibName, for: indexPath) as! NameValueTableViewCell
        cell.name = NSLocalizedString("Minimum Inventory", comment:"settings pencil remaining title")
        if let quantity = AppController.appController.appConfiguration.minInventoryQuantity {
            cell.value = formatDecimalQuantity(quantity)
        } else {
            cell.value = ""
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    fileprivate func configureInAppPurchaseCell(_ indexPath: IndexPath) -> NameValueTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NameValueTableViewCell.nibName, for: indexPath) as! NameValueTableViewCell
        cell.name = NSLocalizedString("Support the Developer", comment:"in app purchase title")
        cell.value = "Please"
        if AppController.appController.appConfiguration.wasPurchasedSuccessfully {
            cell.value = NSLocalizedString("Thank You!", comment:"settings app purchase thank you message")
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    fileprivate func configureDataImportCell(_ indexPath: IndexPath) -> BigButtonTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BigButtonTableViewCell.nibName, for: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Seed Database", comment:"seed database admin function")
        return cell
    }
    
    fileprivate func configureDataExportCell(_ indexPath: IndexPath) -> BigButtonTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BigButtonTableViewCell.nibName, for: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Export Database", comment:"export database admin function")
        return cell
    }
    
    fileprivate func configureSeedSell(_ indexPath: IndexPath) -> BigButtonTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BigButtonTableViewCell.nibName, for: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Create Cloud Data", comment:"create full database in iCloud admin function")
        return cell
    }
    
    fileprivate func formatDecimalQuantity(_ quantity: NSDecimalNumber) -> String {
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

    
    // MARK: tableview delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController: UIViewController?
        
        let ixPath = (indexPath.section, indexPath.row)
        
        switch ixPath {
        case (Sections.dataManagement.rawValue, DataManagementRows.dataExport.rawValue):
            tableView.deselectRow(at: indexPath, animated: false)
            self.showHUD(message: "Creating Export")
            do {
                try self.exportDatabase({ (success, error) -> Void in
                    self.hideHUD()
                    if let e = error {
                        assertionFailure(e.localizedDescription)
                    }
                })
            } catch {
                assertionFailure("Database export failed")
            }
        case (Sections.dataManagement.rawValue, DataManagementRows.dataImport.rawValue):
            self.seedCloudDatabase()
            tableView.deselectRow(at: indexPath, animated: false)
        case (Sections.dataManagement.rawValue, DataManagementRows.dataSeed.rawValue):
            self.confirmCreateDatabase()
            tableView.deselectRow(at: indexPath, animated: false)
        case (Sections.appPurchase.rawValue, _):
            viewController = SettingsPurchaseOptionsTableViewController()
        default:
            viewController = SettingsMinimumStockTableViewController()
        }
        
        if let viewController = viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProductHeaderView") as! ProductHeaderView
        
        switch section {
        case Sections.minimumInventory.rawValue:
            headerView.title = NSLocalizedString("Inventory Management", comment:"settings inventory mananagement section header")
        case Sections.appPurchase.rawValue:
            headerView.title = NSLocalizedString("Purchase", comment:"settings in app purchase section")
        default:
            headerView.title = "Data Management"
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductHeaderView.headerHeight
    }
    
}

