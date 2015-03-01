//
//  CKRecord+AppExtensions.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CloudKit
import Foundation

extension CKRecord {
    
    func assignParentReference(parentRecord parent: CKRecord, relationshipName: String) -> Void {
        let reference = CKReference(record: parent, action: .DeleteSelf)
        self.setObject(reference, forKey: relationshipName)
    }
    
}