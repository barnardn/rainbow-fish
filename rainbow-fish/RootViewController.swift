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
import StoreKit
import GoogleMobileAds

class RootViewController: UITabBarController {

    fileprivate var showingAd: Bool = false
    fileprivate var skPaymentObserver: StoreKitPaymentObserver = StoreKitPaymentObserver()
    
    fileprivate lazy var adBannerView : GADBannerView = {
        let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        return bannerView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.updateProductsNotificationHandler(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.updateStoreKitPurchaseStatus(_:)), name: NSNotification.Name(rawValue: StoreKitPurchaseNotificationName), object: nil)
        viewControllers = [
                InventoryNavigationController(),
                CatalogNavigationController(),
                SettingsNavigationController()
        ]
        SKPaymentQueue.default().add(self.skPaymentObserver)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor;
        if !AppController.appController.appConfiguration.wasPurchasedSuccessfully {
            self.view.insertSubview(self.adBannerView, belowSubview: self.tabBar)
            self.adBannerView.adUnitID = AppController.appController.googleAdUnitId
            self.adBannerView.delegate = self
            self.adBannerView.rootViewController = self
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            self.adBannerView.load(request)
        }
        if AppController.appController.appConfiguration.iCloudRecordID == nil {
            self.obtainCloudRecordId(performUpdate: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !AppController.appController.appConfiguration.wasPurchasedSuccessfully {
            self.adBannerView.frame = CGRect(x: CGFloat(0.0), y: self.tabBar.frame.minY, width: self.view.bounds.width, height: CGFloat(50))
        }
        
    }
    
    // MARK: --= notification handlers =--
    
    func updateProductsNotificationHandler(_ notification: Notification) {
        if let _ = AppController.appController.lastUpdatedDate() as Date? {
            if AppController.appController.shouldPerformAutomaticProductUpdates() {
                self.updateProducts()
            }
        }
    }
    
    func updateStoreKitPurchaseStatus(_ notification: Notification) {
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
            print("Store kit message: \(message)")
            
            // store kit seems to present it's own alerts!
            
        }
    }
    
    fileprivate func disableBannerAds() {
        if let _ = self.adBannerView.superview {
            self.adBannerView.delegate = nil
            self.adBannerView.removeFromSuperview()
        }
    }
    
    // MARK: --= private methods =--
    
    fileprivate func updateProducts() {
        self.showHUD(message: "Updating...")
        CloudManager.sharedManger.refreshManufacturersAndProducts{ [unowned self] (success, error) in
            self.hideHUD()
            if let _ = error {
                self.hideHUD()
                self.presentErrorAlert(title: NSLocalizedString("Unable to Update", comment:"update network error title"), message: NSLocalizedString("Please verify that you are connected to the Internet and that you are signed into iCloud.", comment:"icloud update failed message"))
                AppController.appController.shouldFetchCatalogOnDisplay = true
            } else {
                let _  = AppController.appController.updateLastUpdatedDateToNow()
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: AppNotifications.DidFinishCloudUpdate.rawValue), object: nil)
            
        }
    }
    
    fileprivate func obtainCloudRecordId(performUpdate: Bool) {
        self.showHUD(message: "Setup...")
        CloudManager.sharedManger.fetchUserRecordID({ [unowned self] (recordID, error) -> Void in
            self.hideHUD()
            if let _ = error {
                self.askUserToLoginToiCloud()
                return
            }
            AppController.appController.appConfiguration.iCloudRecordID = recordID
            AppController.appController.appConfiguration.save()
            AppController.appController.icloudCurrentlyAvailable = true
            if !performUpdate {
                return
            }
            CloudManager.sharedManger.refreshManufacturersAndProducts{ [unowned self] (success, error) in
                if let _ = error {
                    self.presentErrorAlert(title: NSLocalizedString("Unable to Update", comment:"update network error title"), message: NSLocalizedString("Please verify that you are connected to the Internet and that you are signed into iCloud.", comment:"icloud update failed message"))
                    AppController.appController.shouldFetchCatalogOnDisplay = true                    
                } else {
                    let _  = AppController.appController.updateLastUpdatedDateToNow()
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: AppNotifications.DidFinishCloudUpdate.rawValue), object: nil)

            }
        })
    }
    
    fileprivate func askUserToLoginToiCloud() {
        let retryAlert = UIAlertController(title: NSLocalizedString("iCloud Login Required", comment:"icloud alert title"), message: NSLocalizedString("This app requires the use of iCloud. Please go to your settings and either log in or create an iCloud account.", comment:"icloud alert message"), preferredStyle: UIAlertControllerStyle.alert);
        let retryAction = UIAlertAction(title: NSLocalizedString("Retry", comment:"retry alert button"), style: UIAlertActionStyle.default) {
            [unowned self] (_) -> Void in
                self.obtainCloudRecordId(performUpdate: true)
        }
        retryAlert.addAction(retryAction)
        self.present(retryAlert, animated: true) { () -> Void in
            retryAlert.view.tintColor = AppearanceManager.appearanceManager.brandColor
        }
        retryAlert.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
    fileprivate func presentStoreKitTransactionMessage(_ message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("In-App Purchase", comment:"app store alert title"), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment:"dismiss alert button title"), style: UIAlertActionStyle.default, handler: nil))
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
        
        let viewController = self.presentedViewController ?? self
        viewController.present(alertController, animated: true) { () -> Void in
            alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
        }
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
}

// MARK: --= iAd banner delegate =--

extension RootViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        if (!AppController.appController.bannerAdIsVisible) {
            UIView.animate(withDuration: 0.5, animations: {() -> Void in
                bannerView.frame = bannerView.frame.offsetBy(dx: 0, dy: -bannerView.frame.height)
            }, completion: { (_) -> Void in
                AppController.appController.bannerAdIsVisible = true
            })
        }
    }

    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        if (!AppController.appController.bannerAdIsVisible) {
            return
        }
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            bannerView.frame = bannerView.frame.offsetBy(dx: 0, dy: bannerView.frame.height)
        }, completion: { (_) -> Void in
            AppController.appController.bannerAdIsVisible = false
        })
    }
    
}


