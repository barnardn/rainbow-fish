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
    
    func importPencilsForProduct(product: Product, modifiedAfterDate: NSDate?, completion: (success: Bool, error: NSError?)->Void) {
        assert(product.recordID != nil, "Must have a CKRecordID")
        let recordID = CKRecordID(recordName: product.recordID!)
        let byRecordID = NSPredicate(format: "%K == %@", ProductAttributes.recordID.rawValue, recordID)
        publicDb.performQuery(CKQuery(recordType: Product.entityName, predicate: byRecordID), inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) { completion(success: false, error: error) }
            } else if  results.count == 0  {
                dispatch_async(dispatch_get_main_queue()) { completion(success: true, error: nil) }
            } else {
                let product = results.first as CKRecord!
                self.pencilsForProduct(product, modifiedAfterDate: modifiedAfterDate) { (results, error) -> Void in
                    if error != nil {
                        dispatch_async(dispatch_get_main_queue()) { completion(success: false, error: error) }
                    } else {
                        self.importPencilRecord(results!, productRecord: product, completion)
                    }
                }
            }
        }
    }
    
    func pencilsForProduct(product: CKRecord, modifiedAfterDate: NSDate?, completion: ([CKRecord]?, NSError?)->Void) {
        let productRef = CKReference(record: product, action: CKReferenceAction.DeleteSelf)
        let byProduct = NSPredicate(format: "%K == %@", PencilRelationships.product.rawValue, productRef)
        var subpredicates = [byProduct!]
        if let modDate = modifiedAfterDate {
            let afterDate = NSPredicate(format: "%K > %@", PencilAttributes.modificationDate.rawValue, modDate)
            subpredicates.append(afterDate!)
        }
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: subpredicates)
        let pencilQuery = CKQuery(recordType: Pencil.entityName, predicate: predicate)
        publicDb.performQuery(pencilQuery, inZoneWithID: nil) { [unowned self] (results, error) -> Void in
            if error != nil {
                completion(nil, error)
                return
            }
            let pencils = results.map{ (obj) -> CKRecord in
                let record = obj as CKRecord
                return record
            }
            completion(pencils, nil)
        }
    }
    
    
    // MARK: core data 
    
    func importManufacturer(manufacturerRecord: CKRecord, productRecords: [CKRecord]?, completion: ()->Void) {

        CoreDataKit.performBlockOnBackgroundContext({(context: NSManagedObjectContext) in
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
    
    func importPencilRecord(records: [CKRecord], productRecord: CKRecord, completion: (Bool, NSError?)->Void) {
        CoreDataKit.performBlockOnBackgroundContext({(context: NSManagedObjectContext) in
            let byID = NSPredicate(format: "%K == %@", ProductAttributes.recordID.rawValue, productRecord.recordID.recordName)
            var result = context.findFirst(Product.self, predicate: byID, sortDescriptors: nil, offset: nil)
            if let error = result.error() {
                assertionFailure(error.localizedDescription)
            }
            let product = result.value()!
            var pencils = records.map{ (pencilRecord: CKRecord) -> Pencil in
                var (pencil, error) = context.updateFromCKRecord(Pencil.self, record: pencilRecord, createIfNotFound: true)
                return pencil!
            }.filter{ return $0.isNew!.boolValue }
            
            if pencils.count > 0 {
                product?.addPencils(NSSet(array: pencils))
            }
            println("New pencils: \(pencils.count) total records \(records.count)")
            return .SaveToPersistentStore
            
            }, completionHandler: { (result: Result<CommitAction>) in
                if let error = result.error() {
                    completion(false, error)
                } else {
                    completion(true, nil)
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
