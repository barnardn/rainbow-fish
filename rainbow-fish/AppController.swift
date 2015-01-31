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

class AppController {
    
    private let modelName: String = "rainbow-fish"
    private let storeName: String = "rainbow-fish.sqlite"
    
    class var appController: AppController {
        struct Singleton {
            static let instance = AppController()
        }
        return Singleton.instance
    }
    
    func setup() {
        NSValueTransformer.setValueTransformer(ColorValueTransformer(), forName: "ColorValueTransformer")
        AppearanceManager.appearanceManager.setupAppearanceProxies()
        CoreDataKit.sharedStack = CoreDataStack(persistentStoreCoordinator: self.persistenStoreCoordinator)

        
    }
    
    // MARK: core data properties
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistenStoreCoordinator: NSPersistentStoreCoordinator = {
        let storeURL = self.urlForResourceInApplicationSupport(resourceName: self.storeName)
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