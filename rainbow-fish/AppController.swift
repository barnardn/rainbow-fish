//
//  AppController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit
import Fabric
import Crashlytics
import UIKit

class AppController: NSObject {
    
    dynamic var bannerAdIsVisible: Bool = false
    
    private let modelName: String = "rainbow-fish"
    private let storeName: String = "rainbow-fish.sqlite"
    private let LastUpdatedDateUserDefaultKey = "LastUpdatedDateUserDefaultKey"
    private let DataImportKey = "CDOImportIdentifier"
    private let config = ConfigurationSettings()
    
    class var appController: AppController {
        struct Singleton {
            static let instance = AppController()
        }
        return Singleton.instance
    }
    
    // MARK: setup and confiugration
    
    func setup() {
        NSValueTransformer.setValueTransformer(ColorValueTransformer(), forName: "ColorValueTransformer")
        Fabric.with([Crashlytics()])
        AppearanceManager.appearanceManager.setupAppearanceProxies()
        CDK.sharedStack = CoreDataStack(persistentStoreCoordinator: self.persistentStoreCoordinator)
    }

    var appConfiguration: ConfigurationSettings  {
        return self.config
    }
    
    lazy var dataImportKey: String = {
        if let infoDict = NSBundle.mainBundle().infoDictionary as! [NSString: AnyObject]? {
            if let importKey = infoDict[self.DataImportKey] as? String {
                println("import key \(importKey)")
                return importKey
            }
        }
        return ""
    }()
    
    func shouldPerformAutomaticProductUpdates() -> Bool {
        if let lastUpdatedDate = NSUserDefaults.standardUserDefaults().objectForKey(LastUpdatedDateUserDefaultKey) as! NSDate? {
            let dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: lastUpdatedDate, toDate: NSDate(), options: NSCalendarOptions.allZeros)
            return (dateComponents.day >= 1)
        }
        return true
    }

    func updateLastUpdatedDateToNow() -> NSDate {
        let now = NSDate()
        NSUserDefaults.standardUserDefaults().setObject(now, forKey: LastUpdatedDateUserDefaultKey)
        return now
    }

    func lastUpdatedDate() -> NSDate? {
        let date = NSUserDefaults.standardUserDefaults().objectForKey(LastUpdatedDateUserDefaultKey) as! NSDate?
        return date
    }
    
    func allowsAppIconBadge() -> Bool {
        var notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        return (notificationSettings.types & UIUserNotificationType.Badge) != nil
    }
    
    func setAppIconBadgeNumber(badgeNumber value: Int) {
        if allowsAppIconBadge() {
            UIApplication.sharedApplication().applicationIconBadgeNumber = value
        }
    }
    
    // MARK: core data properties
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let storeURL = self.urlForResourceInApplicationSupport(resourceName: self.storeName)
        println("Store URL: \(storeURL)")
        return NSPersistentStoreCoordinator(automigrating: true, deleteOnMismatch: true, URL: storeURL, managedObjectModel: self.managedObjectModel)!
    }()
    
    
    // MARK: application folder methods

    lazy var applicationSupportFolderURL: NSURL = {
        return NSFileManager.defaultManager().applicationSupportDirectory()
    }()
    
    func urlForResourceInApplicationSupport(#resourceName: String) -> NSURL {
        return self.applicationSupportFolderURL.URLByAppendingPathComponent(resourceName)
    }
}