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

class RootViewController: UITabBarController {

    private var showingAd: Bool = false
    
    private lazy var adBannerView : ADBannerView = {
        let bannerView = ADBannerView(adType: ADAdType.Banner)
        return bannerView
    }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateProductsNotificationHandler:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        viewControllers = [
                InventoryNavigationController(),
                CatalogNavigationController(),
                SettingsNavigationController()
        ]
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor;
        self.view.insertSubview(self.adBannerView, belowSubview: self.tabBar)
        self.adBannerView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        struct DispatchOnce {
            static var dispatchToken: dispatch_once_t = 0
        }
        dispatch_once(&DispatchOnce.dispatchToken) {
            if let cloudId = AppController.appController.appConfiguration.iCloudRecordID {
                self.updateProducts()
            } else {
                self.obtainCloudRecordId(performUpdate: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.adBannerView.frame = CGRect(x: CGFloat(0.0), y: CGRectGetMinY(self.tabBar.frame), width: CGRectGetWidth(self.view.bounds), height: CGFloat(50))
    }
    
    func updateProductsNotificationHandler(notification: NSNotification) {
        if let lastUpdatedDate = AppController.appController.lastUpdatedDate() as NSDate? {
            if AppController.appController.shouldPerformAutomaticProductUpdates() {
                self.updateProducts()
            }
        }
    }
    
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
    
    private func obtainCloudRecordId(#performUpdate: Bool) {
        self.showHUD(message: "Setup...")
        CloudManager.sharedManger.fetchUserRecordID({ [unowned self] (recordID, error) -> Void in
            if let e = error {
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
                println("hey!!!")
                self.obtainCloudRecordId(performUpdate: true)
        }
        retryAlert.addAction(retryAction)
        self.presentViewController(retryAlert, animated: true, completion: nil)
        retryAlert.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
}


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


