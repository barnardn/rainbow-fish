//
//  NSFileManager+CDOExtensions.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation

extension FileManager {
    
    func applicationSupportDirectory() -> URL {
        
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport =  urls.first!

        do {
            
            let exists = try appSupport.checkResourceIsReachable()
            if !exists {
                try FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true, attributes: nil)
            }
            
        } catch let error as NSError {
            assertionFailure(error.localizedDescription)
        }
        
        return appSupport
    }
    
    
}
