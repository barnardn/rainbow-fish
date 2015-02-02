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
                    self.importManufacturer(manufacturer, productRecords: products)
                    completionHandler()
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
    
    // MARK: core data 
    
    func importManufacturer(manufacturerRecord: CKRecord, productRecords: [CKRecord]?) {

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
