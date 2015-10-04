//
//  RootViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

import CoreData
import CoreDataKit
import iAd
import StoreKit

class RootViewController: UITabBarController {

    private var showingAd: Bool = false
    private var skPaymentObserver: StoreKitPaymentObserver = StoreKitPaymentObserver()
    
    private lazy var adBannerView : ADBannerView = {
        let bannerView = ADBannerView(adType: ADAdType.Banner)
        return bannerView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateProductsNotificationHandler:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateStoreKitPurchaseStatus:"), name: StoreKitPurchaseNotificationName, object: nil)
        viewControllers = [
                InventoryNavigationController(),
                CatalogNavigationController(),
                SettingsNavigationController()
        ]
        SKPaymentQueue.defaultQueue().addTransactionObserver(self.skPaymentObserver)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor;
        if !AppController.appController.appConfiguration.wasPurchasedSuccessfully {
            self.view.insertSubview(self.adBannerView, belowSubview: self.tabBar)
            self.adBannerView.delegate = self
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        struct DispatchOnce {
            static var dispatchToken: dispatch_once_t = 0
        }
        dispatch_once(&DispatchOnce.dispatchToken) {
            if let _ = AppController.appController.appConfiguration.iCloudRecordID {
                self.updateProducts()
            } else {
                self.obtainCloudRecordId(performUpdate: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !AppController.appController.appConfiguration.wasPurchasedSuccessfully {
            self.adBannerView.frame = CGRect(x: CGFloat(0.0), y: CGRectGetMinY(self.tabBar.frame), width: CGRectGetWidth(self.view.bounds), height: CGFloat(50))
        }
        
    }
    
    // MARK: --= notification handlers =--
    
    func updateProductsNotificationHandler(notification: NSNotification) {
        if let _ = AppController.appController.lastUpdatedDate() as NSDate? {
            if AppController.appController.shouldPerformAutomaticProductUpdates() {
                self.updateProducts()
            }
        }
    }
    
    func updateStoreKitPurchaseStatus(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String:AnyObject] {
            var message: String = ""
            let purchaseResult = userInfo[StoreKitPurchaseResultTypeKey] as! String
            switch purchaseResult {
            case StoreKitPurchaseResultType.Completed.rawValue:
                message = NSLocalizedString("Thank you for your purchase!", comment:"completed store kit purchase message")
                disableBannerAds()
            case StoreKitPurchaseResultType.Failed.rawValue:
                message = NSLocalizedString("Your purchase could not be processed.", comment:"failed store kit purchase default message")
                if let error = userInfo[StoreKitPurchaseErrorUserInfoKey] as? NSError {
                    message = error.localizedDescription
                }
            case StoreKitPurchaseResultType.Deferred.rawValue:
                message = NSLocalizedString("Your transaction is being processed. If \"Ask To Buy\" has been enabled for your account, you will have to wait for this purchase to be approved.", comment:"deferred store kit purchase message")
            default:
                print("status returned \(purchaseResult)")
            }
            assert(message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0, "empty message for storekit notification")
            self.presentStoreKitTransactionMessage(message)
        }
    }
    
    private func disableBannerAds() {
        if let _ = self.adBannerView.superview {
            self.adBannerView.delegate = nil
            self.adBannerView.removeFromSuperview()
        }
    }
    
    // MARK: --= private methods =--
    
    private func updateProducts() {
        self.showHUD(message: "Updating...")
        CloudManager.sharedManger.refreshManufacturersAndProducts{ [unowned self] (success, error) in
            if let e = error {
                assertionFailure(e.localizedDescription)
            }
            self.hideHUD()
            let _  = AppController.appController.updateLastUpdatedDateToNow()
            NSNotificationCenter.defaultCenter().postNotificationName(AppNotifications.DidFinishCloudUpdate.rawValue, object: nil)
        }
    }
    
    private func obtainCloudRecordId(performUpdate performUpdate: Bool) {
        self.showHUD(message: "Setup...")
        CloudManager.sharedManger.fetchUserRecordID({ [unowned self] (recordID, error) -> Void in
            if let _ = error {
                self.hideHUD()
                self.askUserToLoginToiCloud()
                return
            }
            AppController.appController.appConfiguration.iCloudRecordID = recordID
            AppController.appController.appConfiguration.save()
            if !performUpdate {
                self.hideHUD()
                return
            }
            CloudManager.sharedManger.refreshManufacturersAndProducts{ [unowned self] (success, error) in
                if let e = error {
                    assertionFailure(e.localizedDescription)
                }
                self.hideHUD()
                NSNotificationCenter.defaultCenter().postNotificationName(AppNotifications.DidFinishCloudUpdate.rawValue, object: nil)
            }
        })
    }
    
    private func askUserToLoginToiCloud() {
        let retryAlert = UIAlertController(title: NSLocalizedString("iCloud Login Required", comment:"icloud alert title"), message: NSLocalizedString("This app requires the use of iCloud. Please go to your settings and either log in or create an iCloud account.", comment:"icloud alert message"), preferredStyle: UIAlertControllerStyle.Alert);
        let retryAction = UIAlertAction(title: NSLocalizedString("Retry", comment:"retry alert button"), style: UIAlertActionStyle.Default) {
            [unowned self] (_) -> Void in
                print("hey!!!")
                self.obtainCloudRecordId(performUpdate: true)
        }
        retryAlert.addAction(retryAction)
        self.presentViewController(retryAlert, animated: true, completion: nil)
        retryAlert.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
    private func presentStoreKitTransactionMessage(message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("In-App Purchase", comment:"app store alert title"), message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment:"dismiss alert button title"), style: UIAlertActionStyle.Default, handler: nil))
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
        
        let viewController = self.presentedViewController ?? self
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

// MARK: --= iAd banner delegate =--

extension RootViewController: ADBannerViewDelegate {
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        if (!AppController.appController.bannerAdIsVisible) {
            UIView.animateWithDuration(0.5, animations: {() -> Void in
                banner.frame = CGRectOffset(banner.frame, 0, -CGRectGetHeight(banner.frame))
            }, completion: { (_) -> Void in
                AppController.appController.bannerAdIsVisible = true
            })
        }
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        if (!AppController.appController.bannerAdIsVisible) {
            return
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            banner.frame = CGRectOffset(banner.frame, 0, CGRectGetHeight(banner.frame))
        }, completion: { (_) -> Void in
            AppController.appController.bannerAdIsVisible = false
        })
    }
    
}


