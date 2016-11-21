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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        AppController.appController.setup()
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        window!.rootViewController = RootViewController()
        window!.tintColor = UIColor.white
        window!.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        CloudManager.sharedManger.refreshManufacturersAndProducts(AppController.appController.lastUpdatedDate()) { (success: Bool, error: NSError?) -> Void in
            if success {
                completionHandler(UIBackgroundFetchResult.newData)
                AppController.appController.updateLastUpdatedDateToNow()
                AppController.appController.shouldFetchCatalogOnDisplay = true
            } else {
                completionHandler(UIBackgroundFetchResult.failed)
            }
        }
    }
    

}

