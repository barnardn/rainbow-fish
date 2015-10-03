//
//  CloudSyncable.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/1/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit
import CloudKit

@objc
protocol CloudSyncable {  // used by NSMangedObject
    
    var recordID: String? { get set }
    var modificationDate: NSDate? { get set }
    var isNew: NSNumber? { get set }
    var ownerRecordIdentifier: String? { get set }
    func populateFromCKRecord(record: CKRecord) -> Void
    func toCKRecord() -> CKRecord
}

extension NSManagedObjectContext {
    
    func updateFromCKRecord<T:NSManagedObject where T:NamedManagedObject, T:CloudSyncable>(entity: T.Type, record: CKRecord, createIfNotFound: Bool) throws -> T? {
        let byRecordID = NSPredicate(format: "recordID == %@", record.recordID.recordName)
        
        if let managedObject = try self.findFirst(entity, predicate: byRecordID, sortDescriptors: nil, offset: nil) {
            if let moDate = managedObject.valueForKeyPath("modificationDate") as? NSDate where moDate.compare(record.modificationDate!) == .OrderedAscending {
                managedObject.populateFromCKRecord(record)
                return managedObject
            }
        } else if createIfNotFound {
            let managedObject = try self.create(T)
            managedObject.populateFromCKRecord(record)
            return managedObject
        }
        return nil
    }
    
}