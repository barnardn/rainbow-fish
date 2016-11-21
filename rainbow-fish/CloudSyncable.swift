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
    var modificationDate: Date? { get set }
    var isNew: NSNumber? { get set }
    var ownerRecordIdentifier: String? { get set }
    func populateFromCKRecord(_ record: CKRecord) -> Void
    func toCKRecord() -> CKRecord
}

extension NSManagedObjectContext {
    
    func updateFromCKRecord<T:NSManagedObject>(_ entity: T.Type, record: CKRecord, createIfNotFound: Bool) throws -> T? where T:NamedManagedObject, T:CloudSyncable {
        let byRecordID = NSPredicate(format: "recordID == %@", record.recordID.recordName)
        
        if let managedObject = try self.findFirst(entity, predicate: byRecordID, sortDescriptors: nil, offset: nil) {
            if let moDate = managedObject.value(forKeyPath: "modificationDate") as? NSDate, moDate.compare(record.modificationDate!) == .orderedAscending {
                managedObject.populateFromCKRecord(record)
                return managedObject
            }
        } else if createIfNotFound {
            let managedObject = try self.create(T.self)
            managedObject.populateFromCKRecord(record)
            return managedObject
        }
        return nil
    }
    
}
