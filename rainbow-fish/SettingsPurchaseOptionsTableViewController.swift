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
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Purchase", comment:"settings in app purchase view title")
        tableView.register(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        if !self.storeKitController.canMakePayments() {
            self.displayCantPayAlert()
            return
        }
        self.showSmallHUD(message: NSLocalizedString("Fetching Prices...", comment:"fetching prices from app store message"))
        self.storeKitController.validateProductIdentifiers { [unowned self] (products) -> Void in
            self.hideSmallHUD()
            var allProducts = [self.storeKitController.restorePurchasesProduct]
            let storeKitProducts = products.sorted(by: { (p1: StoreKitProduct, p2: StoreKitProduct) -> Bool in
                return p1.displayPriceValue < p2.displayPriceValue
            })
            allProducts.append(contentsOf: storeKitProducts)
            self.products = allProducts
            self.tableView.reloadData()
            if !AppController.appController.icloudCurrentlyAvailable {
                self.icloudNotAvailableAlert()
            }
        }
    }

    fileprivate func displayCantPayAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Unable to Make Payments", comment:"unable to make payments alert title"), message: NSLocalizedString("This account is currently not able to make payments. You may need to disable parental controls to allow in-app purchases", comment:"unable to make payments message"), preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("Dismiss", comment:"dismiss alert button title"), style: UIAlertActionStyle.cancel) {
            [unowned self](_) -> Void in
            let _ = self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
    fileprivate func icloudNotAvailableAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Unable to Purchase", comment:"can't purchase alert title"), message: NSLocalizedString("Access to iCloud is currently not available. Please verify that you have signed in to your iCloud account from the Settings app", comment:"icloud not available alert message"), preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("Dismiss", comment:"dismiss alert button title"), style: UIAlertActionStyle.cancel) {
            [unowned self](_) -> Void in
            let _ = self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(action)
        let viewController = self.presentedViewController ?? self
        viewController.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor        
    }
    
    
    // MARK: tableview methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.products?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NameValueTableViewCell.nibName, for: indexPath) as! NameValueTableViewCell
        cell.selectionStyle = .none
        let product = self.products?[indexPath.section] as StoreKitProduct!
        cell.name = product?.name
        cell.value = product?.displayPrice
        cell.tintColor = AppearanceManager.appearanceManager.brandColor
        if let _ = product?.details {
            cell.accessoryType = .detailDisclosureButton
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    //MARK: table view delegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let nameValueCell = cell as! NameValueTableViewCell
            nameValueCell.disabledAppearance = AppController.appController.appConfiguration.wasPurchasedSuccessfully
            nameValueCell.accessoryType = (AppController.appController.appConfiguration.wasPurchasedSuccessfully) ? .none : .disclosureIndicator
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            if AppController.appController.appConfiguration.wasPurchasedSuccessfully {
                return
            }            
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
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let product = self.products?[section]
        return product?.summary
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let product = self.products?[indexPath.section]
        let viewController = ThankYouViewController(message: product?.details)
        self.present(viewController, animated: true, completion: nil)
    }
    
}



