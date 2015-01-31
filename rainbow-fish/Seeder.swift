//
//  Seeder.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/28/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import CloudKit

class Seeder {
    
    private let seedFile: NSString
    private let container: CKContainer
    private let publicDb: CKDatabase
    
    init(seedFile: NSString) {
        self.seedFile = seedFile;
        container = CKContainer.defaultContainer()
        publicDb = container.publicCloudDatabase
    }

    func seedPencilDatabase(completion: (countInserted: Int, error: NSError?) -> ()) {
        
        let seedURL = NSBundle.mainBundle().URLForResource(seedFile, withExtension: "json")
        assert(seedURL != nil, "can't find seed json file")
        if let seedJsonData = NSData(contentsOfURL: seedURL!) {
            var error: NSError? = nil
            let jsonData = NSJSONSerialization.JSONObjectWithData(seedJsonData, options: .AllowFragments, error: &error) as [[String:String]]?
            if error != nil {
                completion(countInserted: 0, error: error)
                return
            }
            let manufacturer = manufacturerWithName("Prismacolor")
            let product = productWithName("Premier", manufacturer: manufacturer)
            let pencils = pencilsWithInfo(jsonData!, forProduct: product)
            var changeSet = [manufacturer, product]
            for p in pencils {
                changeSet.append(p)
            }
            var saveOp =  CKModifyRecordsOperation(recordsToSave: changeSet, recordIDsToDelete: nil)
            saveOp.database = self.publicDb
            saveOp.savePolicy = .AllKeys
            saveOp.modifyRecordsCompletionBlock = {(saved, deleted, error) -> Void in
                if error != nil {
                    completion(countInserted: 0, error: error)
                } else {
                    completion(countInserted: saved!.count, error: nil)
                }
            }
            saveOp.start()
        }
    }
    
    func manufacturerWithName(name: String) -> CKRecord {
        let manufacturer = CKRecord(recordType: Manufacturer.entityName())
        manufacturer.setObject(name, forKey: ManufacturerAttributes.name.rawValue)
        return manufacturer
    }
    
    func productWithName(name: String, manufacturer: CKRecord) -> CKRecord {
        let product = CKRecord(recordType: Product.entityName())
        product.setObject(name, forKey: ProductAttributes.name.rawValue)
        
        let manufactRef = CKReference(record: manufacturer, action: CKReferenceAction.DeleteSelf)
        product.setObject(manufactRef, forKey: ManufacturerRelationships.products.rawValue);
        return product
    }
    
    func pencilsWithInfo(pencilInfo: [[String:String]], forProduct product: CKRecord) -> [CKRecord] {
        let pencilRecords = pencilInfo.map{ (p: [String:String]) -> CKRecord in
            let pencil = CKRecord(recordType: Pencil.entityName())
            pencil.setObject(p[PencilAttributes.name.rawValue], forKey: PencilAttributes.name.rawValue)
            pencil.setObject(p[PencilAttributes.identifier.rawValue], forKey: PencilAttributes.identifier.rawValue)
            let productRef = CKReference(record: product, action: .DeleteSelf)
            pencil.setObject(productRef, forKey: PencilRelationships.product.rawValue)
            return pencil
        }
        return pencilRecords
    }
    
}