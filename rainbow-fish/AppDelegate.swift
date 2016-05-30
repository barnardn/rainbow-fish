//
//  AppDelegate.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/24/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        AppController.appController.setup()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.backgroundColor = UIColor.whiteColor()
        window!.rootViewController = RootViewController()
        window!.tintColor = UIColor.whiteColor()
        window!.makeKeyAndVisible()
        return true
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        CloudManager.sharedManger.refreshManufacturersAndProducts(AppController.appController.lastUpdatedDate()) { (success: Bool, error: NSError?) -> Void in
            if success {
                completionHandler(UIBackgroundFetchResult.NewData)
                AppController.appController.updateLastUpdatedDateToNow()
                AppController.appController.shouldFetchCatalogOnDisplay = true
            } else {
                completionHandler(UIBackgroundFetchResult.Failed)
            }
        }
    }
    

}

