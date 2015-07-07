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
        self.title = NSLocalizedString("Purchases", comment:"settings in app purchase view title")
        tableView.registerNib(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        if !self.storeKitController.canMakePayments() {
            self.displayCantPayAlert()
            return
        }
        self.showHUD(message: NSLocalizedString("Fetching Prices...", comment:"fetching prices from app store message"))
        self.storeKitController.validateProductIdentifiers { [unowned self] (products) -> Void in
            self.hideHUD()
            var allProducts = [self.storeKitController.restorePurchasesProduct]
            let storeKitProducts = products.sorted({ (p1: StoreKitProduct, p2: StoreKitProduct) -> Bool in
                return p1.displayPriceValue < p2.displayPriceValue
            })
            allProducts.extend(storeKitProducts)
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
    
}

extension SettingsPurchaseOptionsTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.products?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NameValueTableViewCell.nibName, forIndexPath: indexPath) as! NameValueTableViewCell
        let product = self.products?[indexPath.section] as StoreKitProduct!
        cell.name = product.name
        cell.value = product.displayPrice
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
 
    //MARK: table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let product = self.products?[indexPath.section]
        println(product)
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let product = self.products?[section]
        return product?.summary
    }
    
    
}



