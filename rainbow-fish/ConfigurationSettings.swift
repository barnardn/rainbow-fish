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
            return UserDefaults.standard.string(forKey: ConfigurationSettingsKey.PurchasedProductIdentifierKey.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsKey.PurchasedProductIdentifierKey.rawValue)
        }
    }
    
    var lastTransactionError: String? {
        get {
            return UserDefaults.standard.string(forKey: ConfigurationSettingsKey.AppPurchaseErrorKey.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsKey.AppPurchaseErrorKey.rawValue)
        }
    }
    
    var wasPurchasedSuccessfully: Bool {
        if let status = purchaseStatus {
            return status.boolValue
        }
        if let status = UserDefaults.standard.integer(forKey: ConfigurationSettingsKey.AppPurchaseStatusKey.rawValue) as Int? {
            return (status == SKPaymentTransactionState.purchased.rawValue)
        }
        return false
    }
    
    override init() {
        super.init()
        iCloudRecordID = UserDefaults.standard.string(forKey: ConfigurationSettingsKey.ICloudKey.rawValue)
        if let minqty = UserDefaults.standard.object(forKey: ConfigurationSettingsKey.MinInventoryQuantityKey.rawValue) as? NSNumber {
            self.minInventoryQuantity = NSDecimalNumber(value: minqty.floatValue as Float)
        }
        purchaseStatus = UserDefaults.standard.object(forKey: ConfigurationSettingsKey.AppPurchaseStatusKey.rawValue) as? NSNumber
    }
    
    func save() {
        UserDefaults.standard.set(self.iCloudRecordID, forKey: ConfigurationSettingsKey.ICloudKey.rawValue)
        UserDefaults.standard.set(self.minInventoryQuantity, forKey: ConfigurationSettingsKey.MinInventoryQuantityKey.rawValue)
        UserDefaults.standard.set(self.purchaseStatus, forKey: ConfigurationSettingsKey.AppPurchaseStatusKey.rawValue)
    }
    
}
