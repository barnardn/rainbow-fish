//
//  Types.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation

enum AppNotifications: String {
    case DidFinishCloudUpdate = "DidFinishCloudUpdate"
    case DidAddPencilToInventory = "DidAddPencilToInventory"
}

enum AppNotificationInfoKeys: String {
    case DidAddPencilToInventoryPencilKey =  "DidAddPencilToInventoryPencilKey"
}
