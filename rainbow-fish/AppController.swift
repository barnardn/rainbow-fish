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
//import Fabric
//import Crashlytics
import UIKit

class AppController: NSObject {
    
    dynamic var bannerAdIsVisible: Bool = false
    
    private let modelName: String = "rainbow-fish"
    private let storeName: String = "rainbow-fish.sqlite"
    private let LastUpdatedDateUserDefaultKey = "LastUpdatedDateUserDefaultKey"
    private let DataImportKey = "CDOImportIdentifier"
    private let InventoryHintUserDefaultsKey = "com.clamdango.rainbow-fish.inventoryhintdisplayed"
    private let config = ConfigurationSettings()
    var icloudCurrentlyAvailable: Bool = false
    
    var didDisplayInventoryHint: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(InventoryHintUserDefaultsKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: InventoryHintUserDefaultsKey)
        }
    }
    
    var shouldFetchCatalogOnDisplay: Bool = false
    
    class var appController: AppController {
        struct Singleton {
            static let instance = AppController()
        }
        return Singleton.instance
    }
    
    // MARK: setup and confiugration
    
    func setup() {
        NSValueTransformer.setValueTransformer(ColorValueTransformer(), forName: "ColorValueTransformer")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("icloudIdentifierDidChange:"), name: NSUbiquityIdentityDidChangeNotification, object: nil)
//        Fabric.with([Crashlytics.self()])
        AppearanceManager.appearanceManager.setupAppearanceProxies()
        CDK.sharedStack = CoreDataStack(persistentStoreCoordinator: self.persistentStoreCoordinator)
    }

    // MARK: ubiquity notification handler
    
    func icloudIdentifierDidChange(notification: NSNotification) {
        if let _ = NSFileManager.defaultManager().ubiquityIdentityToken {
            self.icloudCurrentlyAvailable = true
        } else {
            self.icloudCurrentlyAvailable = false
        }
    }
    
    // MARK: app configuration settings
    
    var appConfiguration: ConfigurationSettings  {
        return self.config
    }
    
    func isNormsiPhone() -> Bool {
        if let ownerCloudId = AppController.appController.appConfiguration.iCloudRecordID where ownerCloudId == AppController.appController.dataImportKey  {
            return true
        }
        return false
    }
    
    lazy var dataImportKey: String = {
        if  let infoDict = NSBundle.mainBundle().infoDictionary ,
            let importKey = infoDict[self.DataImportKey] as? String {
                return importKey
        }
        return ""
    }()
    
    func shouldPerformAutomaticProductUpdates() -> Bool {
        if let lastUpdatedDate = NSUserDefaults.standardUserDefaults().objectForKey(LastUpdatedDateUserDefaultKey) as! NSDate? {
            let dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: lastUpdatedDate, toDate: NSDate(), options: NSCalendarOptions())
            return (dateComponents.day >= 1) && self.icloudCurrentlyAvailable
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
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        return (notificationSettings!.types.intersect(UIUserNotificationType.Badge)) != []
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
        print("Store URL: \(storeURL)")
        return NSPersistentStoreCoordinator(automigrating: true, deleteOnMismatch: true, URL: storeURL, managedObjectModel: self.managedObjectModel)!
    }()
    
    
    // MARK: application folder methods

    lazy var applicationSupportFolderURL: NSURL = {
        return NSFileManager.defaultManager().applicationSupportDirectory()
    }()
    
    func urlForResourceInApplicationSupport(resourceName resourceName: String) -> NSURL {
        return self.applicationSupportFolderURL.URLByAppendingPathComponent(resourceName)
    }
}