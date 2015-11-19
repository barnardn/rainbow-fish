//
//  SettingsPurchaseRestoreTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 11/16/15.
//  Copyright © 2015 Clamdango. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

class SettingsPurchaseRestoreTableViewController: UITableViewController {

    var restoreRequest: SKReceiptRefreshRequest?
    
    lazy var storeKitController : StoreKitController = {
        return StoreKitController()
    }()

    convenience init() {
        self.init(style: .Grouped)
        self.title = NSLocalizedString("Restore Purchases", comment:"settings restore purchases view title")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StoreKitPurchaseNotificationName, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        self.tableView.contentInset = UIEdgeInsets(top: 40.0, left: 0, bottom: 0, right: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "purchaseNotificationHandler:", name: StoreKitPurchaseNotificationName, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let restoreRequest = self.restoreRequest where self.navigationController?.topViewController == self {
            restoreRequest.cancel()
        }
        self.hideSmallHUD()
        super.viewWillDisappear(animated)
    }
    
    func purchaseNotificationHandler(notification: NSNotification) {
        self.hideSmallHUD()
    }
    
    // MARK: private api
    
    private func requestReceiptRefresh() {
        let restoreRequest = SKReceiptRefreshRequest()
        restoreRequest.delegate = self
        restoreRequest.start()
        self.restoreRequest = restoreRequest
        self.showSmallHUD(message: NSLocalizedString("Restoring Purchase...", comment:"settings restore purchase hud message"))
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BigButtonTableViewCell.nibName, forIndexPath: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Restore Purchase", comment:"settings restore purchase button title")
        return cell
    }

    // MARK: - tableview delegate
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("If you have already purchased Rainbow Fish, tap \"Restore Purchase\" to restore your purchase from The App Store. You will not be billed for restoring your purchase.", comment:"settings resstore purchase instructions message")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.requestReceiptRefresh()
        
    }
    
}

extension SettingsPurchaseRestoreTableViewController: SKRequestDelegate {
    
    func requestDidFinish(request: SKRequest) {
        self.restoreRequest = nil
        SKPaymentQueue.defaultQueue().restoreCompletedTransactionsWithApplicationUsername(AppController.appController.appConfiguration.iCloudRecordID!)
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        self.restoreRequest = nil
        print("Purchase restore returned \(error.localizedDescription)")
        self.hideSmallHUD()
        let title = NSLocalizedString("Unable to Refresh Receipt", comment:"settings restore purchase receipt refresh alert title")
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment:"alert dismiss button title"), style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
}