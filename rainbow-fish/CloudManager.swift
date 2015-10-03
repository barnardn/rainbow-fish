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
            if let recordID = recordID {
                print("found iCloud record id: \(recordID.recordName)")
                id = recordID.recordName.sha1()
            }
            dispatch_async(dispatch_get_main_queue()) { completion(recordID: id, error: error) }
        }
    }
    
    // MARK: cloud methods

    func refreshManufacturersAndProducts(sinceDate: NSDate?, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        var query = CKQuery(recordType: Manufacturer.entityName, predicate: NSPredicate(value: true))
        if let lastModifiedDate = sinceDate {
            let predicate = NSPredicate(format: "%K > %@", ManufacturerAttributes.modificationDate.rawValue, lastModifiedDate)
            query = CKQuery(recordType: Manufacturer.entityName, predicate: predicate)
        }
        
        publicDb.performQuery(query, inZoneWithID: CKRecordZone.defaultRecordZone().zoneID) {[unowned self](results, error) in
            if error != nil  {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(success: false, error: error) }
                return
            }
            if results?.count == 0 {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(success: true, error: nil) }
                return
            }
            let queryOperations = results?.map({ (o: AnyObject) -> CKRecord in
                return o as! CKRecord
            }).map({ (mrec: CKRecord) -> CKQueryOperation in
                var isLast = false
                if let lastRec = results?.last as CKRecord! {
                    isLast = (lastRec == mrec)
                }
                return self.productsQuery(mrec, isLastOperation: isLast, importCompletion: completionHandler)
            })
            
            let lastOperation = queryOperations!.last
            for qop in queryOperations! {
                if qop != lastOperation {
                    lastOperation?.addDependency(qop)
                }
                self.publicDb.addOperation(qop)
            }
        }
    }
    
    func refreshManufacturersAndProducts(completionHandler: (success: Bool, error: NSError?) -> Void ) {
        self.refreshManufacturersAndProducts(nil, completionHandler: completionHandler)
    }

    func productsQuery(manufacturer: CKRecord, isLastOperation: Bool, importCompletion: (success: Bool, error: NSError?) -> Void) -> CKQueryOperation {
        let manufactRef = CKReference(record: manufacturer, action: CKReferenceAction.DeleteSelf)
        let predicate = NSPredicate(format: "%K == %@", ProductRelationships.manufacturer.rawValue, manufactRef)
        
        let productQuery = CKQuery(recordType: Product.entityName, predicate: predicate)
        productQuery.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let queryOperation = CKQueryOperation(query: productQuery)
        var productRecords = [CKRecord]()
        queryOperation.recordFetchedBlock = {(record: CKRecord) in
            productRecords.append(record)
        }
        queryOperation.queryCompletionBlock = {[unowned self] (cursor: CKQueryCursor?, error: NSError?) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) { importCompletion(success: false, error: error) }
                return
            }
            if cursor != nil {
                self.continueProductsQuery(manufacturer, cursor: cursor!, productRecords: productRecords, isLastOperation: isLastOperation, completion: importCompletion)
            } else {
                self.storeManufacturer(manufacturer, productRecords: productRecords, completion: { () -> Void in
                    if isLastOperation {
                        dispatch_async(dispatch_get_main_queue()) { importCompletion(success: true, error: nil) }
                    }
                })
            }
                
        }
        return queryOperation
    }
    
    func continueProductsQuery(manufacturer: CKRecord, cursor: CKQueryCursor, var productRecords: [CKRecord], isLastOperation: Bool, completion: (success: Bool, error: NSError?) -> Void) {
        
        let operation = CKQueryOperation(cursor: cursor)
        operation.recordFetchedBlock = {(record: CKRecord) in
            productRecords.append(record)
        }
        
        operation.queryCompletionBlock = {[unowned self] (continueCursor: CKQueryCursor?, error: NSError?) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completion(success: false, error: error) })
            } else {
                if continueCursor != nil {
                    self.continueProductsQuery(manufacturer, cursor: continueCursor!, productRecords: productRecords, isLastOperation: isLastOperation, completion: completion)
                } else {
                    if isLastOperation {
                        dispatch_async(dispatch_get_main_queue()) { completion(success: true, error: nil) }
                    }
                }
            }
        }
        self.publicDb.addOperation(operation)
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
        pencilQuery.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true)]
        
        var pencilRecords = [CKRecord]()
    
        let operation = CKQueryOperation(query: pencilQuery)
        operation.resultsLimit = CKQueryOperationMaximumResults
        
        operation.recordFetchedBlock = {(record: CKRecord) in
            pencilRecords.append(record)
        }
    
        operation.queryCompletionBlock = {[unowned self](cursor: CKQueryCursor?, error: NSError?) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) { completion(success: false, error: error) }
            } else {
                if cursor != nil {
                    self.createQueryOperation(product, cursor: cursor!, results: pencilRecords, completion: completion)
                } else {
                    self.storePencilRecords(pencilRecords, forProduct: product, completion: completion)
                }
            }
        }
        self.publicDb.addOperation(operation)
    }
    
    
    private func createQueryOperation(product: Product, cursor: CKQueryCursor!, var results: [CKRecord], completion: (success: Bool, error: NSError?)->Void) -> Void {
        let queryOperation = CKQueryOperation(cursor: cursor)
        queryOperation.resultsLimit = CKQueryOperationMaximumResults
        
        queryOperation.recordFetchedBlock = {(record: CKRecord) in
            results.append(record)
        }
        
        queryOperation.queryCompletionBlock = { [unowned self] (nextCursor: CKQueryCursor?, error: NSError?) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) { completion(success: false, error: error) }
            } else {
                if nextCursor != nil {
                    self.createQueryOperation(product, cursor: nextCursor!, results: results, completion: completion)
                } else {
                    self.storePencilRecords(results, forProduct: product, completion: completion)
                }
            }
        }
        self.publicDb.addOperation(queryOperation)
    }

    
    func storePencilRecords(pencilRecords: [CKRecord], forProduct product: Product, completion: (Bool, NSError?)->Void) {
        
        print("Storing \(pencilRecords.count) pencil records")
        
        CDK.performBlockOnBackgroundContext({(context: NSManagedObjectContext) in
            
            var pencilObjects = [Pencil]()
            for record in pencilRecords {
                do {
                    if let pencil = try? context.updateFromCKRecord(Pencil.self, record: record, createIfNotFound: true) {
                        pencilObjects.append(pencil!)
                    }
                }
            }
            let pencils = pencilObjects.filter{ return ($0.isNew?.boolValue)! }
            
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
            return .SaveToPersistentStore
            
            }, completionHandler: { (result) in
                do {
                    try result()
                    dispatch_async(dispatch_get_main_queue()) { completion(true, nil) }
                } catch {
                    let nserror = NSError(domain: "com.clamdango.rainbowfish", code: 100, userInfo: [NSLocalizedDescriptionKey : "store pencil failure"])
                    dispatch_async(dispatch_get_main_queue()) { completion(false, nserror) }
                }
        })
    }
    
    func syncChangeSet(changeSet: [CKRecord], completion: (success: Bool, savedRecords:[CKRecord]?, error: NSError?) -> Void) {
        let saveOp =  CKModifyRecordsOperation(recordsToSave: changeSet, recordIDsToDelete: nil)
        saveOp.database = self.publicDb
        saveOp.savePolicy = .AllKeys
        saveOp.modifyRecordsCompletionBlock = {(saved, deleted, error) in
            if let e = error {
                dispatch_async(dispatch_get_main_queue()) { completion(success: false, savedRecords: nil, error: e) }
            }
            let savedRecords = saved?.map({ (o: AnyObject) -> CKRecord in
                return o as! CKRecord
            })
            dispatch_async(dispatch_get_main_queue()) { completion(success: true, savedRecords: savedRecords, error: nil) }
        }
        saveOp.start()
    }
    
    // MARK: core data
    
    func storeManufacturer(manufacturerRecord: CKRecord, productRecords: [CKRecord]?, completion: ()->Void) {

        CDK.performBlockOnBackgroundContext({(context: NSManagedObjectContext) in
            
            if let value = try? context.updateFromCKRecord(Manufacturer.self, record: manufacturerRecord, createIfNotFound: true),
               let manufacturer = value
            {
                if let productRecords = productRecords {
                    
                    var products = [Product]()
                    for record in productRecords {
                        if let product = try? context.updateFromCKRecord(Product.self, record: record, createIfNotFound: true) {
                            products.append(product!)
                        } else {
                            assertionFailure()
                        }
                    }
                    manufacturer.products = NSSet(array: products)
                } else {
                    manufacturer.products = NSSet()
                }
            }
            return .SaveToPersistentStore
            
        }, completionHandler: {(result) in
            do {
                try result()
                completion()
            } catch CoreDataKitError.CoreDataError(let coreDataError) {
                assertionFailure("Core Data Error \(coreDataError)")
            } catch {
                assertionFailure()
            }
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
