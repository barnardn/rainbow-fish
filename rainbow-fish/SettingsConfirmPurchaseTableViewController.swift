//
//  SettingsConfirmPurchaseTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 7/11/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
import StoreKit

class SettingsConfirmPurchaseTableViewController: UITableViewController {

    var purchaseProduct: StoreKitProduct!
    var appStoreProduct: SKProduct!
    
    convenience init(selectedProduct: StoreKitProduct, appStoreProduct: SKProduct) {
        self.init(style: .Grouped)
        self.purchaseProduct = selectedProduct
        self.appStoreProduct = appStoreProduct
        self.title = NSLocalizedString("Confirm", comment:"settings confirm view purchase title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        self.tableView.contentInset = UIEdgeInsets(top: 40.0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Buy Now!", comment:"settings purchase option button title format")
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.bounds.width), height: 24.0))
        headerLabel.textAlignment = .Center
        headerLabel.font = AppearanceManager.appearanceManager.nameLabelFont
        headerLabel.textColor = UIColor.darkGrayColor()
        let messageFormat = String(format: NSLocalizedString("Purchase \"%@\" for %@", comment:"settings purchase item title"), self.purchaseProduct.name, self.purchaseProduct.displayPrice)
        headerLabel.text = String(format: messageFormat, self.purchaseProduct.name, self.purchaseProduct.displayPrice)
        return headerLabel
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(48.0)
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let messageFormat = NSLocalizedString("Tap \"Buy Now!\" above to purchase the \"%@\" option for %@ ", comment:"settings confirm purchase instructions")
        return String(format: messageFormat, self.purchaseProduct.name, self.purchaseProduct.displayPrice)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let payment = SKMutablePayment(product: self.appStoreProduct)
        payment.quantity = 1
        payment.applicationUsername = AppController.appController.appConfiguration.iCloudRecordID!
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    
}