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

    fileprivate var kvoContext = 0
    var purchaseProduct: StoreKitProduct!
    var appStoreProduct: SKProduct!
    
    convenience init(selectedProduct: StoreKitProduct, appStoreProduct: SKProduct) {
        self.init(style: .grouped)
        self.purchaseProduct = selectedProduct
        self.appStoreProduct = appStoreProduct
        self.title = NSLocalizedString("Confirm", comment:"settings confirm view purchase title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        self.tableView.contentInset = UIEdgeInsets(top: 40.0, left: 0, bottom: 0, right: 0)
        AppController.appController.appConfiguration.addObserver(self, forKeyPath: "purchaseStatus", options: .new, context: &kvoContext)
    }
    
    deinit {
        AppController.appController.appConfiguration.removeObserver(self, forKeyPath: "purchaseStatus", context: &kvoContext)
    }
    
    // MARK: kvo handler
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvoContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        //change[NSKeyValueChangeKey.newKey]
        if  let keyPath = keyPath, keyPath == "purchaseStatus",
            let change = change,
            let statusValue = change[.newKey] as! Int?
        {
            if self.navigationController?.topViewController == self && statusValue == SKPaymentTransactionState.purchased.rawValue {
                let _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BigButtonTableViewCell.nibName, for: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Buy Now!", comment:"settings purchase option button title format")
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.bounds.width), height: 24.0))
        headerLabel.textAlignment = .center
        headerLabel.font = AppearanceManager.appearanceManager.nameLabelFont
        headerLabel.textColor = UIColor.darkGray
        let messageFormat = String(format: NSLocalizedString("Purchase \"%@\" for %@", comment:"settings purchase item title"), self.purchaseProduct.name, self.purchaseProduct.displayPrice)
        headerLabel.text = String(format: messageFormat, self.purchaseProduct.name, self.purchaseProduct.displayPrice)
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(48.0)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let messageFormat = NSLocalizedString("Tap \"Buy Now!\" above to purchase the \"%@\" option for %@ ", comment:"settings confirm purchase instructions")
        return String(format: messageFormat, self.purchaseProduct.name, self.purchaseProduct.displayPrice)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payment = SKMutablePayment(product: self.appStoreProduct)
        payment.quantity = 1
        payment.applicationUsername = AppController.appController.appConfiguration.iCloudRecordID!
        SKPaymentQueue.default().add(payment)
    }
    
    
}
