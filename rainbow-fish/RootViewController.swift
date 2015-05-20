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

class RootViewController: UITabBarController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateProductsNotificationHandler:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        viewControllers = [
                InventoryNavigationController(),
                PencilNavigationController(),
                SettingsNavigationController()
        ]
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor;
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
    
    func updateProductsNotificationHandler(notification: NSNotification) {
        if let lastUpdatedDate = AppController.appController.lastUpdatedDate() as NSDate? {
            if AppController.appController.shouldPerformAutomaticProductUpdates() {
                self.updateProducts()
            }
        }
    }
    
    private func updateProducts() {
        self.showHUD(header: "Updating Pencils", footer: "Please wait...")
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
        self.showHUD(header: "Performing Setup", footer: "Please Wait...")
        CloudManager.sharedManger.fetchUserRecordID({ [unowned self] (recordID, error) -> Void in
            if let e = error {
                self.hideHUD()
                self.askUserToLoginToiCloud()
                return
            }
            AppController.appController.appConfiguration.iCloudRecordID = recordID
            CDK.mainThreadContext.save(nil)
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
    
    
    //MARK: seed cloudkit
    //TODO: REMOVE BEFORE APP SUBMISSION!!
    
//    private func makeRain() {
//        showHUD(header: "Making Rain", footer: "Please Wait...")
//        JHProgressHUD.sharedHUD.showInView(self.view, withHeader: "Making Rain", andFooter: "Please Wait...")
//        var seeder = Seeder(seedFile: "prismacolor-pencils")
//        seeder.seedPencilDatabase { [unowned self](countInserted, error) -> () in
//            self.hideHUD()
//            if error == nil {
//                println("inserted: \(countInserted)")
//                self.showHUD(header: "Updating Pencils", footer: "Please wait...")
//                CloudManager.sharedManger.refreshManufacturersAndProducts{ [unowned self] () in
//                    self.hideHUD()
//                }
//            } else {
//                println(error)
//            }
//        }
//    }
//    
    
}
