//
//  ConfigurationSettings.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 6/13/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation

class ConfigurationSettings: NSObject {

    enum ConfigurationSettingsKey: String {
        case icloudKey = "com.clamdango.ranbow-fish.icloudid"
        case minInventoryQuantityKey = "com.clamdango.ranbow-fish.minqty"
    }
    
    dynamic var iCloudRecordID: String?
    dynamic var minInventoryQuantity: NSDecimalNumber?
    
    override init() {
        super.init()
        iCloudRecordID = NSUserDefaults.standardUserDefaults().stringForKey(ConfigurationSettingsKey.icloudKey.rawValue)
        minInventoryQuantity = NSUserDefaults.standardUserDefaults().objectForKey(ConfigurationSettingsKey.minInventoryQuantityKey.rawValue) as? NSDecimalNumber
    }
    
    func save() {
        NSUserDefaults.standardUserDefaults().setObject(self.iCloudRecordID, forKey: ConfigurationSettingsKey.icloudKey.rawValue)
        NSUserDefaults.standardUserDefaults().setObject(self.minInventoryQuantity, forKey: ConfigurationSettingsKey.minInventoryQuantityKey.rawValue)
    }
    
}