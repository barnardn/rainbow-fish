//
//  CloudManager.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/31/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import CoreDataKit

class CloudManager {
    
    private let container: CKContainer
    private let publicDb: CKDatabase
    private let privateDb: CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDb = container.publicCloudDatabase
        privateDb = container.privateCloudDatabase
    }
    
    // MARK: permissions methods
    
    func checkiCloudAccessibility(completion: ((isAvailable: Bool, errorMessage: String) -> Void)) {
        self.container.accountStatusWithCompletionHandler { (status, error) -> Void in
            var available: Bool = false
            var message = ""
            switch status {
            case .Available:
                available = true
            case .NoAccount:
                message = NSLocalizedString("You must set up an iCloud account to use Rainbow Fish.", comment:"create an iCloud account mesage")
            default:
                message = "iCloud returned the following error: \(error?.localizedFailureReason). You may have limited functionality"
            }
            dispatch_async(dispatch_get_main_queue()) { completion(isAvailable: available, errorMessage: message) }
        }
    }
    
    func fetchUserRecordID(completion: (recordID: String?, error: NSError?) -> Void) {
        self.container.fetchUserRecordIDWithCompletionHandler { (recordID, error) -> Void in
            var id: String?
            if recordID != nil {
                println("found iCloud record id: \(recordID.recordName)")
                id = recordID.recordName.sha1()
            }
            dispatch_async(dispatch_get_main_queue()) { completion(recordID: id, error: error) }
        }
    }
    
    // MARK: cloud methods

    func refreshManufacturersAndProducts(completionHandler: (success: Bool, error: NSError?) -> Void ) {
        var queryAll = CKQuery(recordType: Manufacturer.entityName, predicate: NSPredicate(value: true))
        publicDb.performQuery(queryAll, inZoneWithID: CKRecordZone.defaultRecordZone().zoneID) {[unowned self](results, error) in
            if error != nil  {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(success: false, error: error) }
                return
            }
            if results.count == 0 {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(success: true, error: nil) }
                return
            }
            var queryOperations = results.map({ (o: AnyObject) -> CKRecord in
                return o as! CKRecord
            }).map({ (mrec: CKRecord) -> CKQueryOperation in
                var isLast = false
                if let lastRec = results.last as? CKRecord {
                    isLast = (lastRec == mrec)
                }
                return self.productsQuery(mrec, isLastOperation: isLast, importCompletion: completionHandler)
            })
            let lastOperation = queryOperations.last
            for qop in queryOperations {
                if qop != lastOperation {
                    lastOperation?.addDependency(qop)
                }
                self.publicDb.addOperation(qop)
            }
        }
    }

    func productsQuery(manufacturer: CKRecord, isLastOperation: Bool, importCompletion: (success: Bool, error: NSError?) -> Void) -> CKQueryOperation {
        let manufactRef = CKReference(record: manufacturer, action: CKReferenceAction.DeleteSelf)
        let predicate = NSPredicate(format: "%K == %@", ProductRelationships.manufacturer.rawValue, manufactRef)
        var productQuery = CKQuery(recordType: Product.entityName, predicate: predicate)
        let queryOperation = CKQueryOperation(query: productQuery)
        var productRecords = [CKRecord]()
        queryOperation.recordFetchedBlock = {(record: CKRecord!) in
            productRecords.append(record)
        }
        queryOperation.queryCompletionBlock = {[unowned self] (cursor: CKQueryCursor!, error: NSError!) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) { importCompletion(success: false, error: error) }
                return
            }
            if cursor != nil {
                let fetchMoreOperation = CKQueryOperation(cursor: cursor)
                fetchMoreOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                fetchMoreOperation.completionBlock = queryOperation.completionBlock
                self.publicDb.addOperation(fetchMoreOperation)
            } else {
                self.importManufacturer(manufacturer, productRecords: productRecords, completion: { () -> Void in
                    if isLastOperation {
                        dispatch_async(dispatch_get_main_queue()) { importCompletion(success: true, error: nil) }
                    }
                })
            }
                
        }
        return queryOperation
    }
    
    func importAllPencilsForProduct(product: Product, modifiedAfterDate: NSDate?, completion: (success: Bool, error: NSError?)->Void) {
        assert(product.recordID != nil, "Must have a CKRecordID")
        let productRecordId = CKRecordID(recordName: product.recordID!)
        let productRef = CKReference(recordID: productRecordId, action: .DeleteSelf)
        let byProduct = NSPredicate(format: "%K == %@", PencilRelationships.product.rawValue, productRef)
        var subpredicates = [byProduct]
        if let modDate = modifiedAfterDate {
            let afterDate = NSPredicate(format: "%K > %@", PencilAttributes.modificationDate.rawValue, modDate)
            subpredicates.append(afterDate)
        }
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: subpredicates)
        let pencilQuery = CKQuery(recordType: Pencil.entityName, predicate: predicate)
        let queryOperation = CKQueryOperation(query: pencilQuery) as CKQueryOperation
        var pencilRecords = [CKRecord]()
        queryOperation.recordFetchedBlock = {(record: CKRecord!) in
            pencilRecords.append(record)
        }
        queryOperation.queryCompletionBlock = {[unowned self] (cursor: CKQueryCursor!, error: NSError!) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) { completion(success: false, error: error) }
            }
            if cursor != nil {
                let fetchMoreOperation = CKQueryOperation(cursor: cursor)
                fetchMoreOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                fetchMoreOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                self.publicDb.addOperation(fetchMoreOperation)
            } else {
                self.storePencilRecords(pencilRecords, forProduct: product, completion: completion)
            }
        }
        self.publicDb.addOperation(queryOperation)
    }
    
    func storePencilRecords(pencilRecords: [CKRecord], forProduct product: Product, completion: (Bool, NSError?)->Void) {
        CDK.performBlockOnBackgroundContext({(context: NSManagedObjectContext) in
            var pencils = pencilRecords.map{ (record: CKRecord) -> Pencil in
                var (pencil, error) = context.updateFromCKRecord(Pencil.self, record: record, createIfNotFound: true)
                return pencil!
            }.filter{ return $0.isNew!.boolValue }
            let localProduct = context.objectWithID(product.objectID) as! Product
    
            if pencils.count > 0 {
                localProduct.addPencils(NSSet(array: pencils))
            }
            if let syncInfo = product.syncInfo {
                syncInfo.lastRefreshTime = NSDate()
            } else {
                localProduct.syncInfo = SyncInfo(managedObjectContext: context)
                localProduct.syncInfo?.lastRefreshTime = NSDate()
            }
            println("New pencils: \(pencils.count) total records \(pencilRecords.count)")
            return .SaveToPersistentStore
            
            }, completionHandler: { (result: Result<CommitAction>) in
                if let error = result.error() {
                    dispatch_async(dispatch_get_main_queue()) { completion(false, error) }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { completion(true, nil) }
                }
        })
    }
    
    func syncChangeSet(changeSet: [CKRecord], completion: (success: Bool, savedRecords:[CKRecord]?, error: NSError?) -> Void) {
        var saveOp =  CKModifyRecordsOperation(recordsToSave: changeSet, recordIDsToDelete: nil)
        saveOp.database = self.publicDb
        saveOp.savePolicy = .AllKeys
        saveOp.modifyRecordsCompletionBlock = {(saved, deleted, error) in
            if let e = error {
                dispatch_async(dispatch_get_main_queue()) { completion(success: false, savedRecords: nil, error: e) }
            }
            let savedRecords = saved.map({ (o: AnyObject) -> CKRecord in
                return o as! CKRecord
            })
            dispatch_async(dispatch_get_main_queue()) { completion(success: true, savedRecords: savedRecords, error: nil) }
        }
        saveOp.start()
    }
    
    // MARK: core data
    
    func importManufacturer(manufacturerRecord: CKRecord, productRecords: [CKRecord]?, completion: ()->Void) {

        CDK.performBlockOnBackgroundContext({(context: NSManagedObjectContext) in
            let (manufacturer, error) = context.updateFromCKRecord(Manufacturer.self, record: manufacturerRecord, createIfNotFound: true)
            assert(error == nil, "Unable to update manufacturer record \(error?.localizedDescription)")
            var products = productRecords?.map{ (prec: CKRecord) -> Product in
                var (product, prodError) = context.updateFromCKRecord(Product.self, record: prec, createIfNotFound: true)
                assert(prodError == nil, "Unable to save product \(prodError?.localizedDescription)")
                return product!
            }
            if let products = products {
                manufacturer?.products = NSSet(array:products)
            } else {
                manufacturer?.products = NSSet()
            }
            return .SaveToPersistentStore
        }, completionHandler: {(result: Result<CommitAction>) in
            if let error = result.error() {
                assertionFailure("Unable to import to core data \(error.localizedDescription)")
            }
            completion()
        })
    }

    // MARK: shared singleton instance
    
    class var sharedManger: CloudManager {
        struct Singleton {
            static let sharedInstance = CloudManager()
        }
        return Singleton.sharedInstance
    }
    
}
