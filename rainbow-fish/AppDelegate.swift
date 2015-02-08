//
//  AppDelegate.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/24/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AppController.appController.setup()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.backgroundColor = UIColor.whiteColor()
        window!.rootViewController = RootViewController()
        window!.tintColor = UIColor.whiteColor()
        window!.makeKeyAndVisible()
        return true
    }


}

