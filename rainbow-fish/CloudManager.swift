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
    
    init() {
        container = CKContainer.defaultContainer()
        publicDb = container.publicCloudDatabase
    }
    
    // MARK: cloud methods
    
    func refreshManufacturersAndProducts(completionHandler: () -> Void ) {
        var queryAll = CKQuery(recordType: Manufacturer.entityName(), predicate: NSPredicate(value: true))

        publicDb.performQuery(queryAll, inZoneWithID: CKRecordZone.defaultRecordZone().zoneID) {[unowned self](results, error) in
            for m in results {
                let manufacturer = m as CKRecord
                self.productsForManufacturer(manufacturer, completion: { (products, error) -> Void in
                    assert(error == nil, "Can't get products \(error!.localizedDescription)")
                    self.importManufacturer(manufacturer, productRecords: products, completionHandler)
                })
            }
        }
    }
    
    func productsForManufacturer(manufacturer: CKRecord, completion: ([CKRecord]?, NSError?)->Void) {
        let manufactRef = CKReference(record: manufacturer, action: CKReferenceAction.DeleteSelf)
        let predicate = NSPredicate(format: "%K == %@", ProductRelationships.manufacturer.rawValue, manufactRef)
        var productQuery = CKQuery(recordType: Product.entityName(), predicate: predicate)
        publicDb.performQuery(productQuery, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                completion(nil, error)
                return
            }
            let productRecords = results.map{ (obj) -> CKRecord in
                let rec = obj as CKRecord
                return rec
            }
            completion(productRecords, nil)
        }
    }
    
    func importAllPencilsForProduct(product: Product, modifiedAfterDate: NSDate?, completion: (success: Bool, error: NSError?)->Void) {
        assert(product.recordID != nil, "Must have a CKRecordID")
        let productRecordId = CKRecordID(recordName: product.recordID!)
        let productRef = CKReference(recordID: productRecordId, action: .DeleteSelf)
        let byProduct = NSPredicate(format: "%K == %@", PencilRelationships.product.rawValue, productRef)
        var subpredicates = [byProduct!]
        if let modDate = modifiedAfterDate {
            let afterDate = NSPredicate(format: "%K > %@", PencilAttributes.modificationDate.rawValue, modDate)
            subpredicates.append(afterDate!)
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
            let localProduct = context.objectWithID(product.objectID) as Product
    
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
                return o as CKRecord
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
