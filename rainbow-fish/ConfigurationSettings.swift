//
//  ConfigurationSettings.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 6/13/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import StoreKit

class ConfigurationSettings: NSObject {

    enum ConfigurationSettingsKey: String {
        case ICloudKey = "com.clamdango.ranbow-fish.icloudid"
        case MinInventoryQuantityKey = "com.clamdango.ranbow-fish.minqty"
        case AppPurchaseStatusKey = "com.clamdango.ranbow-fish.purchase-status"
        case PurchasedProductIdentifierKey = "com.clamdango.ranbow-fish.product"
        case AppPurchaseErrorKey = "com.clamdango.ranbow-fish.purchase-error"
    }
    
    dynamic var iCloudRecordID: String?
    dynamic var minInventoryQuantity: NSDecimalNumber?
    dynamic var purchaseStatus: NSNumber?
    
    var purchasedProduct: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(ConfigurationSettingsKey.PurchasedProductIdentifierKey.rawValue)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: ConfigurationSettingsKey.PurchasedProductIdentifierKey.rawValue)
        }
    }
    
    var lastTransactionError: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(ConfigurationSettingsKey.AppPurchaseErrorKey.rawValue)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: ConfigurationSettingsKey.AppPurchaseErrorKey.rawValue)
        }
    }
    
    var wasPurchasedSuccessfully: Bool {
        if let status = NSUserDefaults.standardUserDefaults().integerForKey(ConfigurationSettingsKey.AppPurchaseStatusKey.rawValue) as Int? {
            return (status == SKPaymentTransactionState.Purchased.rawValue)
        }
        return false
    }
    
    override init() {
        super.init()
        iCloudRecordID = NSUserDefaults.standardUserDefaults().stringForKey(ConfigurationSettingsKey.ICloudKey.rawValue)
        minInventoryQuantity = NSUserDefaults.standardUserDefaults().objectForKey(ConfigurationSettingsKey.MinInventoryQuantityKey.rawValue) as? NSDecimalNumber
        purchaseStatus = NSUserDefaults.standardUserDefaults().objectForKey(ConfigurationSettingsKey.AppPurchaseStatusKey.rawValue) as? NSNumber
    }
    
    func save() {
        NSUserDefaults.standardUserDefaults().setObject(self.iCloudRecordID, forKey: ConfigurationSettingsKey.ICloudKey.rawValue)
        NSUserDefaults.standardUserDefaults().setObject(self.minInventoryQuantity, forKey: ConfigurationSettingsKey.MinInventoryQuantityKey.rawValue)
    }
    
    
    
    
}