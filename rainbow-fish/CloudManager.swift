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
    
    fileprivate let container: CKContainer
    fileprivate let publicDb: CKDatabase
    fileprivate let privateDb: CKDatabase
    
    init() {
        container = CKContainer.default()
        publicDb = container.publicCloudDatabase
        privateDb = container.privateCloudDatabase
    }
    
    // MARK: permissions methods
    
    func checkiCloudAccessibility(_ completion: @escaping ((_ isAvailable: Bool, _ errorMessage: String) -> Void)) {
        self.container.accountStatus { (status, error) -> Void in
            var available: Bool = false
            var message = ""
            switch status {
            case .available:
                available = true
            case .noAccount:
                message = NSLocalizedString("You must set up an iCloud account to use Rainbow Fish.", comment:"create an iCloud account mesage")
            default:
                message = "iCloud error. You may have limited functionality"
                if let emsg = error?.localizedDescription {
                    message = "iCloud returned the following error: \(emsg). You may have limited functionality."
                }
            }
            DispatchQueue.main.async { completion(available, message) }
        }
    }
    
    func fetchUserRecordID(_ completion: @escaping (_ recordID: String?, _ error: NSError?) -> Void) {
        self.container.fetchUserRecordID { (recordID, error) -> Void in
            var id: String?
            if let recordID = recordID {
                print("found iCloud record id: \(recordID.recordName)")
                id = recordID.recordName.sha1()
            }
            DispatchQueue.main.async { completion(id, error as NSError?) }
        }
    }
    
    // MARK: cloud methods

    func refreshManufacturersAndProducts(_ sinceDate: Date?, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        var query = CKQuery(recordType: Manufacturer.entityName, predicate: NSPredicate(value: true))
        if let lastModifiedDate = sinceDate {
            let predicate = NSPredicate(format: "%K > %@", ManufacturerAttributes.modificationDate.rawValue, lastModifiedDate as CVarArg)
            query = CKQuery(recordType: Manufacturer.entityName, predicate: predicate)
        }
        
        publicDb.perform(query, inZoneWith: CKRecordZone.default().zoneID) {[unowned self](results, error) in
            if error != nil  {
                DispatchQueue.main.async { completionHandler(false, error as NSError?) }
                return
            }
            if results?.count == 0 {
                DispatchQueue.main.async { completionHandler(true, nil) }
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
                self.publicDb.add(qop)
            }
        }
    }
    
    func refreshManufacturersAndProducts(_ completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void ) {
        self.refreshManufacturersAndProducts(nil, completionHandler: completionHandler)
    }

    func productsQuery(_ manufacturer: CKRecord, isLastOperation: Bool, importCompletion: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> CKQueryOperation {
        let manufactRef = CKReference(record: manufacturer, action: CKReferenceAction.deleteSelf)
        let predicate = NSPredicate(format: "%K == %@", ProductRelationships.manufacturer.rawValue, manufactRef)
        
        let productQuery = CKQuery(recordType: Product.entityName, predicate: predicate)
        productQuery.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let queryOperation = CKQueryOperation(query: productQuery)
        var productRecords = [CKRecord]()
        queryOperation.recordFetchedBlock = {(record: CKRecord) in
            productRecords.append(record)
        }
        
        queryOperation.queryCompletionBlock = {[unowned self] (cursor, error) in
            if error != nil {
                DispatchQueue.main.async { importCompletion(false, error as NSError?) }
                return
            }
            if cursor != nil {
                self.continueProductsQuery(manufacturer, cursor: cursor!, productRecords: productRecords, isLastOperation: isLastOperation, completion: importCompletion)
            } else {
                self.storeManufacturer(manufacturer, productRecords: productRecords, completion: { () -> Void in
                    if isLastOperation {
                        DispatchQueue.main.async { importCompletion(true,  error as NSError?) }
                    }
                })
            }
                
        }
        return queryOperation
    }
    
    func continueProductsQuery(_ manufacturer: CKRecord, cursor: CKQueryCursor, productRecords: [CKRecord], isLastOperation: Bool, completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        var currentRecords = productRecords
        
        let operation = CKQueryOperation(cursor: cursor)
        operation.recordFetchedBlock = {(record: CKRecord) in
            currentRecords.append(record)
        }
        
        operation.queryCompletionBlock = {[unowned self] (continueCursor, error) in
            if error != nil {
                DispatchQueue.main.async(execute: { completion(false, error as NSError?) })
            } else {
                if continueCursor != nil {
                    self.continueProductsQuery(manufacturer, cursor: continueCursor!, productRecords: currentRecords, isLastOperation: isLastOperation, completion: completion)
                } else {
                    if isLastOperation {
                        DispatchQueue.main.async { completion(true, error as NSError?) }
                    }
                }
            }
        }
        self.publicDb.add(operation)
    }
    
    
    
    func importAllPencilsForProduct(_ product: Product, modifiedAfterDate: Date?, completion: @escaping (_ success: Bool, _ error: NSError?)->Void) {
        assert(product.recordID != nil, "Must have a CKRecordID")

        let productRecordId = CKRecordID(recordName: product.recordID!)
        let productRef = CKReference(recordID: productRecordId, action: .deleteSelf)
        let byProduct = NSPredicate(format: "%K == %@", PencilRelationships.product.rawValue, productRef)
        var subpredicates = [byProduct]
        
        if let modDate = modifiedAfterDate {
            let afterDate = NSPredicate(format: "%K > %@", PencilAttributes.modificationDate.rawValue, modDate as CVarArg)
            subpredicates.append(afterDate)
        }
        
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: subpredicates)
        let pencilQuery = CKQuery(recordType: Pencil.entityName, predicate: predicate)
        pencilQuery.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true)]
        
        var pencilRecords = [CKRecord]()
    
        let operation = CKQueryOperation(query: pencilQuery)
        operation.resultsLimit = CKQueryOperationMaximumResults
        
        operation.recordFetchedBlock = {(record: CKRecord) in
            pencilRecords.append(record)
        }
    
        operation.queryCompletionBlock = {[unowned self] (cursor , error) in
            if error != nil {
                DispatchQueue.main.async { completion(false, error as NSError?) }
            } else {
                if cursor != nil {
                    self.createQueryOperation(product, cursor: cursor!, results: pencilRecords, completion: completion)
                } else {
                    self.storePencilRecords(pencilRecords, forProduct: product, completion: completion)
                }
            }
        }
        self.publicDb.add(operation)
    }
    
    
    fileprivate func createQueryOperation(_ product: Product, cursor: CKQueryCursor!, results: [CKRecord], completion: @escaping (_ success: Bool, _ error: NSError?)->Void) -> Void {
        let queryOperation = CKQueryOperation(cursor: cursor)
        queryOperation.resultsLimit = CKQueryOperationMaximumResults
        
        var currentResults = results
        
        queryOperation.recordFetchedBlock = {(record: CKRecord) in
            currentResults.append(record)
        }
        
        queryOperation.queryCompletionBlock = { [unowned self] (nextCursor, error ) in
            if error != nil {
                DispatchQueue.main.async { completion(false, error as NSError?) }
            } else {
                if nextCursor != nil {
                    self.createQueryOperation(product, cursor: nextCursor!, results: currentResults, completion: completion)
                } else {
                    self.storePencilRecords(results, forProduct: product, completion: completion)
                }
            }
        }
        self.publicDb.add(queryOperation)
    }

    
    func storePencilRecords(_ pencilRecords: [CKRecord], forProduct product: Product, completion: @escaping (Bool, NSError?)->Void) {
        
        print("Storing \(pencilRecords.count) pencil records")
        
        CDK.performOnBackgroundContext(block: {(context: NSManagedObjectContext) in
            
            var pencilObjects = [Pencil]()
            for record in pencilRecords {
                do {
                    if let pencil = try? context.updateFromCKRecord(Pencil.self, record: record, createIfNotFound: true) {
                        pencilObjects.append(pencil!)
                    }
                }
            }
            let pencils = pencilObjects.filter{ return ($0.isNew?.boolValue)! }
            
            let localProduct = context.object(with: product.objectID) as! Product
    
            if pencils.count > 0 {
                localProduct.addPencils(NSSet(array: pencils))
            }
            if let syncInfo = product.syncInfo {
                syncInfo.lastRefreshTime = Date()
            } else {
                localProduct.syncInfo = SyncInfo(managedObjectContext: context)
                localProduct.syncInfo?.lastRefreshTime = Date()
            }
            return .saveToPersistentStore
            
            }, completionHandler: { (result) in
                
                do {
                    let _ = try result()
                    DispatchQueue.main.async { completion(true, nil) }
                } catch {
                    let nserror = NSError(domain: "com.clamdango.rainbowfish", code: 100, userInfo: [NSLocalizedDescriptionKey : "store pencil failure"])
                    DispatchQueue.main.async { completion(false, nserror) }
                }
        })
    }
    
    func syncChangeSet(_ changeSet: [CKRecord], completion: @escaping (_ success: Bool, _ savedRecords:[CKRecord]?, _ error: NSError?) -> Void) {
        let saveOp =  CKModifyRecordsOperation(recordsToSave: changeSet, recordIDsToDelete: nil)
        saveOp.database = self.publicDb
        saveOp.savePolicy = .allKeys
        saveOp.modifyRecordsCompletionBlock = {(saved, deleted, error) in
            if let e = error {
                DispatchQueue.main.async { completion(false, nil, e as NSError?) }
            }
            let savedRecords = saved?.map({ (o: AnyObject) -> CKRecord in
                return o as! CKRecord
            })
            DispatchQueue.main.async { completion(true, savedRecords, nil) }
        }
        saveOp.start()
    }
    
    // MARK: core data
    
    func storeManufacturer(_ manufacturerRecord: CKRecord, productRecords: [CKRecord]?, completion: @escaping ()->Void) {

        CDK.performOnBackgroundContext(block: {(context: NSManagedObjectContext) in
            
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
            return .saveToPersistentStore
            
        }, completionHandler: {(result) in
            do {
                let _ = try result()
                completion()
            } catch CoreDataKitError.coreDataError(let coreDataError) {
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
