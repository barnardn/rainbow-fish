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
    var ownerRecordIdentifer: String? { get set }
    func populateFromCKRecord(record: CKRecord) -> Void
    func toCKRecord() -> CKRecord
}

extension NSManagedObjectContext {
    
    func updateFromCKRecord<T:NSManagedObject where T:NamedManagedObject, T:CloudSyncable>(entity: T.Type, record: CKRecord, createIfNotFound: Bool) -> (T?,NSError?) {
        
        var returnResult: (T?, NSError?) = (nil, nil)
        let byRecordID = NSPredicate(format: "recordID == %@", record.recordID.recordName)
        
        switch self.findFirst(entity, predicate: byRecordID, sortDescriptors: nil, offset: nil) {
            
        case let .Failure(error):
            returnResult = (nil,error)
            
        case let .Success(boxedResult):
            if let managedObject = boxedResult.value as T! {
                if let moDate = managedObject.valueForKeyPath("modificationDate") as? NSDate {
                    if moDate.compare(record.modificationDate)  == .OrderedAscending {
                        managedObject.populateFromCKRecord(record)
                        managedObject.ownerRecordIdentifer = record.creatorUserRecordID.recordName
                    }
                }
                returnResult = (managedObject, nil)
            } else {
                if createIfNotFound {
                    var managedObject = self.create(T).value()
                    managedObject?.populateFromCKRecord(record)
                    managedObject?.ownerRecordIdentifer = record.creatorUserRecordID.recordName
                    returnResult = (managedObject, nil)
                }
            }

        }
        return returnResult
    }
    
    
    
}