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
    
    fileprivate let modelName: String = "rainbow-fish"
    fileprivate let storeName: String = "rainbow-fish.sqlite"
    fileprivate let LastUpdatedDateUserDefaultKey = "LastUpdatedDateUserDefaultKey"
    fileprivate let DataImportKey = "CDOImportIdentifier"
    fileprivate let InventoryHintUserDefaultsKey = "com.clamdango.rainbow-fish.inventoryhintdisplayed"
    fileprivate let config = ConfigurationSettings()
    var icloudCurrentlyAvailable: Bool = false
    
    var didDisplayInventoryHint: Bool {
        get {
            return UserDefaults.standard.bool(forKey: InventoryHintUserDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: InventoryHintUserDefaultsKey)
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
        ValueTransformer.setValueTransformer(ColorValueTransformer(), forName: NSValueTransformerName(rawValue: "ColorValueTransformer"))
        NotificationCenter.default.addObserver(self, selector: #selector(AppController.icloudIdentifierDidChange(_:)), name: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil)
        if let _ = FileManager.default.ubiquityIdentityToken {
            self.icloudCurrentlyAvailable = true
        } else {
            self.icloudCurrentlyAvailable = false
        }
        Fabric.with([Crashlytics.self])
        AppearanceManager.appearanceManager.setupAppearanceProxies()
        CDK.sharedStack = CoreDataStack(persistentStoreCoordinator: self.persistentStoreCoordinator)
    }

    // MARK: ubiquity notification handler
    
    func icloudIdentifierDidChange(_ notification: Notification) {
        print("icloudIdentifierDidChange")
        if let _ = FileManager.default.ubiquityIdentityToken {
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
        if let ownerCloudId = AppController.appController.appConfiguration.iCloudRecordID, ownerCloudId == AppController.appController.dataImportKey  {
            return true
        }
        return false
    }
    
    lazy var dataImportKey: String = {
        if  let infoDict = Bundle.main.infoDictionary ,
            let importKey = infoDict[self.DataImportKey] as? String {
                return importKey
        }
        return ""
    }()
    
    func shouldPerformAutomaticProductUpdates() -> Bool {
        if let lastUpdatedDate = UserDefaults.standard.object(forKey: LastUpdatedDateUserDefaultKey) as! Date? {
            let dateComponents = (Calendar.current as NSCalendar).components(NSCalendar.Unit.day, from: lastUpdatedDate, to: Date(), options: NSCalendar.Options())
            return (dateComponents.day! >= 1) && self.icloudCurrentlyAvailable
        }
        return true
    }

    @discardableResult func updateLastUpdatedDateToNow() -> Date {
        let now = Date()
        UserDefaults.standard.set(now, forKey: LastUpdatedDateUserDefaultKey)
        return now
    }

    func lastUpdatedDate() -> Date? {
        let date = UserDefaults.standard.object(forKey: LastUpdatedDateUserDefaultKey) as! Date?
        return date
    }
    
    func allowsAppIconBadge() -> Bool {
        let notificationSettings = UIApplication.shared.currentUserNotificationSettings
        return (notificationSettings!.types.intersection(UIUserNotificationType.badge)) != []
    }
    
    func setAppIconBadgeNumber(badgeNumber value: Int) {
        if allowsAppIconBadge() {
            UIApplication.shared.applicationIconBadgeNumber = value
        }
    }
    
    // MARK: google admob settings
    
    lazy var googleAdUnitId: String = {
        guard let
            infoDictionary = Bundle.main.infoDictionary as? [String:AnyObject?],
            let googleAdUnitID = infoDictionary["GoogleAdUnitID"] as? String else {
                
                return "ca-app-pub-3940256099942544/2934735716"
                
        }
        return googleAdUnitID
    }()
    
    // MARK: core data properties
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let storeURL = self.urlForResourceInApplicationSupport(resourceName: self.storeName)        
        print("Store URL: \(storeURL)")
        return NSPersistentStoreCoordinator(automigrating: true, deleteOnMismatch: true, URL: storeURL, managedObjectModel: self.managedObjectModel)!
    }()
    
    
    // MARK: application folder methods

    lazy var applicationSupportFolderURL: URL = {
        return FileManager.default.applicationSupportDirectory()
    }()
    
    func urlForResourceInApplicationSupport(resourceName: String) -> URL {
        return self.applicationSupportFolderURL.appendingPathComponent(resourceName)
    }
}
