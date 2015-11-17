//
//  SettingsPurchaseOptionsTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 6/28/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class SettingsPurchaseOptionsTableViewController: UITableViewController {
    
    let storeKitController = StoreKitController()
    var products: [StoreKitProduct]?
    
    convenience init() {
        self.init(style: .Grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Purchase", comment:"settings in app purchase view title")
        tableView.registerNib(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        if !self.storeKitController.canMakePayments() {
            self.displayCantPayAlert()
            return
        }
        self.showSmallHUD(message: NSLocalizedString("Fetching Prices...", comment:"fetching prices from app store message"))
        self.storeKitController.validateProductIdentifiers { [unowned self] (products) -> Void in
            self.hideSmallHUD()
            var allProducts = [self.storeKitController.restorePurchasesProduct]
            let storeKitProducts = products.sort({ (p1: StoreKitProduct, p2: StoreKitProduct) -> Bool in
                return p1.displayPriceValue < p2.displayPriceValue
            })
            allProducts.appendContentsOf(storeKitProducts)
            self.products = allProducts
            self.tableView.reloadData()
        }
    }

    private func displayCantPayAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Unable to Make Payments", comment:"unable to make payments alert title"), message: NSLocalizedString("This account is currently not able to make payments. You may need to disable parental controls to allow in-app purchases", comment:"unable to make payments message"), preferredStyle: .Alert)
        let action = UIAlertAction(title: NSLocalizedString("Dismiss", comment:"dismiss alert button title"), style: UIAlertActionStyle.Cancel) {
            [unowned self](_) -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: tableview methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.products?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NameValueTableViewCell.nibName, forIndexPath: indexPath) as! NameValueTableViewCell
        cell.selectionStyle = .None
        let product = self.products?[indexPath.section] as StoreKitProduct!
        cell.name = product.name
        cell.value = product.displayPrice
        cell.tintColor = AppearanceManager.appearanceManager.brandColor
        if let _ = product.details {
            cell.accessoryType = .DetailDisclosureButton
        } else {
            cell.accessoryType = .DisclosureIndicator
        }
        return cell
    }
    
    //MARK: table view delegate

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let nameValueCell = cell as! NameValueTableViewCell
            nameValueCell.disabledAppearance = AppController.appController.appConfiguration.wasPurchasedSuccessfully
            nameValueCell.accessoryType = (AppController.appController.appConfiguration.wasPurchasedSuccessfully) ? .None : .DisclosureIndicator
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let viewController = SettingsPurchaseRestoreTableViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        
        if  let product = self.products?[indexPath.section],
            let appStoreProduct = self.storeKitController.skProduct(forProduct: product) {
            let viewController = SettingsConfirmPurchaseTableViewController(selectedProduct: product, appStoreProduct: appStoreProduct)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let product = self.products?[section]
        return product?.summary
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let product = self.products?[indexPath.section]
        let viewController = ThankYouViewController(message: product?.details)
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
}



