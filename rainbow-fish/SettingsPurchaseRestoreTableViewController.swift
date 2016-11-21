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
        self.init(style: .grouped)
        self.title = NSLocalizedString("Restore Purchases", comment:"settings restore purchases view title")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: StoreKitPurchaseNotificationName), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: BigButtonTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: BigButtonTableViewCell.nibName)
        self.tableView.contentInset = UIEdgeInsets(top: 40.0, left: 0, bottom: 0, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsPurchaseRestoreTableViewController.purchaseNotificationHandler(_:)), name: NSNotification.Name(rawValue: StoreKitPurchaseNotificationName), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let restoreRequest = self.restoreRequest, self.navigationController?.topViewController == self {
            restoreRequest.cancel()
        }
        self.hideSmallHUD()
        super.viewWillDisappear(animated)
    }
    
    func purchaseNotificationHandler(_ notification: Notification) {
        self.hideSmallHUD()
    }
    
    // MARK: private api
    
    fileprivate func requestReceiptRefresh() {
        let restoreRequest = SKReceiptRefreshRequest()
        restoreRequest.delegate = self
        restoreRequest.start()
        self.restoreRequest = restoreRequest
        self.showSmallHUD(message: NSLocalizedString("Restoring Purchase...", comment:"settings restore purchase hud message"))
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BigButtonTableViewCell.nibName, for: indexPath) as! BigButtonTableViewCell
        cell.title = NSLocalizedString("Restore Purchase", comment:"settings restore purchase button title")
        return cell
    }

    // MARK: - tableview delegate
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("If you have already purchased Rainbow Fish, tap \"Restore Purchase\" to restore your purchase from The App Store. You will not be billed for restoring your purchase.", comment:"settings resstore purchase instructions message")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.requestReceiptRefresh()
        
    }
    
}

extension SettingsPurchaseRestoreTableViewController: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        self.restoreRequest = nil
        SKPaymentQueue.default().restoreCompletedTransactions(withApplicationUsername: AppController.appController.appConfiguration.iCloudRecordID!)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.restoreRequest = nil
        print("Purchase restore returned \(error.localizedDescription)")
        self.hideSmallHUD()
        let title = NSLocalizedString("Unable to Refresh Receipt", comment:"settings restore purchase receipt refresh alert title")
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment:"alert dismiss button title"), style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
}
