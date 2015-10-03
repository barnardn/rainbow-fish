//
//  NSFileManager+CDOExtensions.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation

extension NSFileManager {
    
    func applicationSupportDirectory() -> NSURL {
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupport =  urls.last as NSURL!
        
        var error: NSError?
        if !appSupport.checkResourceIsReachableAndReturnError(&error) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(appSupport, withIntermediateDirectories: true, attributes: nil)
            } catch let createError as NSError {
                assertionFailure(createError.localizedDescription)
            }
        }
        return appSupport
    }
    
    
}