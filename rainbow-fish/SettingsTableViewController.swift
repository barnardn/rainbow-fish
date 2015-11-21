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
        case AppPurchase
        case DataManagement
    }
    
    enum InventoryRows: Int {
        case MinimumInventory
    }
    
    enum AppPurchaseRows: Int {
        case InAppPurchaseRow
    }
    
    enum DataManagementRows: Int {
        case DataExport
        case DataImport
        case DataSeed
    }
    
    private var settingsContext = 0
    private var allowDataImportSection = false
    
    private lazy var cloudImporter: CloudImport = {
        return CloudImport()
    }()
    
    var sectionInfo = [ [InventoryRows.MinimumInventory.rawValue], [AppPurchaseRows.InAppPurchaseRow.rawValue], [DataManagementRows.DataExport.rawValue, DataManagementRows.DataImport.rawValue] ]
    
    convenience init() {
        self.init(style: .Grouped)
        let image = UIImage(named: "tabbar-icon-settings")?.imageWithRenderingMode(.AlwaysTemplate)
        self.title = NSLocalizedString("Settings", comment:"setting navigation item title")
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment:"setting tabbar item title"), image: image, tag: 0)
        
        if AppController.appController.isNormsiPhone() {
            var _ = self.sectionInfo.removeLast()
            self.sectionInfo.append([DataManagementRows.DataExport.rawValue, DataManagementRows.DataImport.rawValue, DataManagementRows.DataSeed.rawValue])
        }
    
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "minInventoryQuantity", context: &settingsContext)
        self.removeObserver(self, forKeyPath: "purchaseStatus", context: &settingsContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        
        self.tableView.registerClass(ProductHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProductHeaderView")
        
        AppController.appController.appConfiguration.addObserver(self, forKeyPath: "minInventoryQuantity", options: .New, context: &settingsContext)
        AppController.appController.appConfiguration.addObserver(self, forKeyPath: "purchaseStatus", options: .New, context: &settingsContext)
        
        if AppController.appController.isNormsiPhone() {
            allowDataImportSection = true
        }
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !AppController.appController.allowsAppIconBadge() {
            let settings = UIUserNotificationSettings(forTypes: .Badge, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }
    

    // MARK: kvo 
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &settingsContext else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        switch keyPath! {
            case "minInventoryQuantity":
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: Sections.MinimumInventory.rawValue)], withRowAnimation: .None)
            case "purchaseStatus":
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: Sections.AppPurchase.rawValue)], withRowAnimation: .None)
            default:
                assertionFailure("unknown keypath observed \(keyPath)")
        }
    }
    
    // MARK: methods
    
    func exportDatabase (completionHandler: (success: Bool, error: NSError?) -> Void ) throws {
        CDK.performBlockOnBackgroundContext({ (context: NSManagedObjectContext) in

            do {
                let results = try context.find(Manufacturer.self)
                let database = NSMutableArray(capacity: results.count)
                for mfg in results {
                    database.addObject(mfg.toJson(true))
                }
                let outUrl = AppController.appController.urlForResourceInApplicationSupport(resourceName: "database.json")
                if let obj = try? NSJSONSerialization.dataWithJSONObject(database, options: .PrettyPrinted) {
                    obj.writeToURL(outUrl, atomically: true)
                    dispatch_async(dispatch_get_main_queue()) { completionHandler(success: true, error: nil) }
                }
                
            } catch CoreDataKitError.CoreDataError(let coreDataError) {
                let nserror = NSError(domain: "com.clamdango.rainbowfish", code: 100, userInfo: [NSLocalizedDescriptionKey : "\(coreDataError)"])
                completionHandler(success: false, error: nserror)
                
            } catch {
                completionHandler(success: false, error: nil)
            }
            
            return CommitAction.DoNothing
            
            }, completionHandler: nil)
        
    }
    
    func seedCloudDatabase() {
        
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
    
    func createDatabaseFromSeedJson() {
        print("Full database import")
    }
    
    
    
    //MARK: tableview data source
    
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
        case (Sections.DataManagement.rawValue, DataManagementRows.DataSeed.rawValue):
            return self.configureSeedSell(indexPath)
        case (Sections.AppPurchase.rawValue, AppPurchaseRows.InAppPurchaseRow.rawValue):
            return self.configureInAppPurchaseCell(indexPath)
        default:
            return self.configureInventoryCell(indexPath)
        }
    }
    
    private func configureInventoryCell(indexPath: NSIndexPath) -> NameValueTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NameValueTableViewCell.nibName, forIndexPath: indexPath) as! NameValueTableViewCell
        cell.name = NSLocalizedString("Minimum Inventory", comment:"settings pencil remaining title")
        if let quantity = AppController.appController.appConfiguration.minInventoryQuantity {
            cell.value = formatDecimalQuantity(quantity)
        } else {
            cell.value = "0"
        }
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    private func configureInAppPurchaseCell(indexPath: NSIndexPath) -> NameValueTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NameValueTableViewCell.nibName, forIndexPath: indexPath) as! NameValueTableViewCell
        cell.name = NSLocalizedString("Support the Developer", comment:"in app purchase title")
        cell.value = "Please"
        if AppController.appController.appConfiguration.wasPurchasedSuccessfully {
            cell.value = NSLocalizedString("Thank You!", comment:"settings app purchase thank you message")
        }
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    private func configureDataImportCell(indexPath: NSIndexPath) -> BigButtonTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Seed Database", comment:"seed database admin function")
        return cell
    }
    
    private func configureDataExportCell(indexPath: NSIndexPath) -> BigButtonTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Export Database", comment:"export database admin function")
        return cell
    }
    
    private func configureSeedSell(indexPath: NSIndexPath) -> BigButtonTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Create Cloud Data", comment:"create full database in iCloud admin function")
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

    
    // MARK: tableview delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController: UIViewController?
        
        let ixPath = (indexPath.section, indexPath.row)
        
        switch ixPath {
        case (Sections.DataManagement.rawValue, DataManagementRows.DataExport.rawValue):
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
        case (Sections.DataManagement.rawValue, DataManagementRows.DataImport.rawValue):
            self.seedCloudDatabase()
        case (Sections.DataManagement.rawValue, DataManagementRows.DataSeed.rawValue):
            self.createDatabaseFromSeedJson()
        case (Sections.AppPurchase.rawValue, _):
            viewController = SettingsPurchaseOptionsTableViewController()
        default:
            viewController = SettingsMinimumStockTableViewController()
        }
        
        if let viewController = viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProductHeaderView") as! ProductHeaderView
        
        switch section {
        case Sections.MinimumInventory.rawValue:
            headerView.title = NSLocalizedString("Inventory Management", comment:"settings inventory mananagement section header")
        case Sections.AppPurchase.rawValue:
            headerView.title = NSLocalizedString("Purchase", comment:"settings in app purchase section")
        default:
            headerView.title = "Data Management"
        }
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductHeaderView.headerHeight
    }
    
}

