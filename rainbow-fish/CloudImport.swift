//
//  CloudImport.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 4/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CloudKit
import Foundation
import SwiftyJSON

class CloudImport {
    
    let ImportFilename: String = "database.json"
    fileprivate let container: CKContainer
    fileprivate let publicDb: CKDatabase
    
    init() {
        container = CKContainer.default()
        publicDb = container.publicCloudDatabase
    }

    func seedToCloud (_ completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { [unowned self] () -> Void in
         
            let databaseUrl = AppController.appController.urlForResourceInApplicationSupport(resourceName: self.ImportFilename)
            let jsonData = try? Data(contentsOf: databaseUrl as URL)
            if jsonData == nil {
                assertionFailure("Cant load seed file")
            }
            var readError: NSError?
            let databaseJSON = JSON(data: jsonData!, error: &readError)
            if let err = readError {
                self.dispatchCompletionHandler(completionHandler, success: false, error: err)
                return
            }
            
            let modifyOperations = databaseJSON.arrayValue.map{ [unowned self] (mfgJSON: JSON) -> CKModifyRecordsOperation in
                let records = self.mfgTree(mfgJSON)
                let mop =  CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                mop.savePolicy = .allKeys
                return mop
            }
            let lastOp = modifyOperations.last!
            lastOp.modifyRecordsCompletionBlock = { [unowned self] (saved, deleted, error) in
                if let err = error as NSError? {
                    self.dispatchCompletionHandler(completionHandler, success: false, error: err)
                } else {
                    self.dispatchCompletionHandler(completionHandler, success: true, error: nil)
                }
            }
            for mop in modifyOperations {
                if mop != lastOp {
                    lastOp.addDependency(mop)
                }
                self.publicDb.add(mop)
            }
        }
    }
    
    fileprivate func mfgTree(_ json: JSON) -> [CKRecord] {
        
        var accumulator = [CKRecord]()

        let mfgRec = self.createCKRecord(Manufacturer.entityName, json: json)
        mfgRec.setValue(json[ManufacturerAttributes.name.rawValue].string, forKey: ManufacturerAttributes.name.rawValue)
        mfgRec.setValue(json[ManufacturerAttributes.ownerRecordIdentifier.rawValue].string, forKey: ManufacturerAttributes.ownerRecordIdentifier.rawValue)
        accumulator.append(mfgRec)
        if let products = json[ManufacturerRelationships.products.rawValue].array {
            let productRecords = self.productTree(productJSON: products, mfg: mfgRec)
            accumulator += productRecords
        }
        return accumulator
    }
    
    fileprivate func productTree(productJSON: [JSON], mfg: CKRecord) -> [CKRecord] {
        
        var accumulator = [CKRecord]()
        
        for json in productJSON {
            let prodRec = self.createCKRecord(Product.entityName, json: json)
            prodRec.setValue(json[ProductAttributes.name.rawValue].string, forKey: ProductAttributes.name.rawValue)
            prodRec.setValue(json[ProductAttributes.ownerRecordIdentifier.rawValue].string, forKey: ProductAttributes.ownerRecordIdentifier.rawValue)
            let mfgRelation = CKReference(record: mfg, action: .deleteSelf)
            prodRec.setObject(mfgRelation, forKey: ProductRelationships.manufacturer.rawValue)
            accumulator.append(prodRec)
            if let pencils = json[ProductRelationships.pencils.rawValue].array {
                let pencilRecords = self.pencils(pencilJSON: pencils, product: prodRec)
                if pencilRecords.count > 0 {
                    accumulator += pencilRecords
                }
            }
        }
        return accumulator
    }
    
    fileprivate func pencils(pencilJSON: [JSON], product: CKRecord) -> [CKRecord] {
        
        return pencilJSON.map{ (json: JSON) -> CKRecord in
            let pencilRec = self.createCKRecord(Pencil.entityName, json: json)
            pencilRec.setValue(json[PencilAttributes.name.rawValue].string, forKey: PencilAttributes.name.rawValue)
            pencilRec.setValue(json[PencilAttributes.identifier.rawValue].string, forKey: PencilAttributes.identifier.rawValue)
            pencilRec.setValue(json[PencilAttributes.color.rawValue].string, forKey: PencilAttributes.color.rawValue)
            pencilRec.setValue(json[PencilAttributes.ownerRecordIdentifier.rawValue].string, forKey: PencilAttributes.ownerRecordIdentifier.rawValue)
            let prodRelation = CKReference(record: product, action: .deleteSelf)
            pencilRec.setObject(prodRelation, forKey: PencilRelationships.product.rawValue)
            return pencilRec
        }
    }
    
    fileprivate func createCKRecord(_ entityName: String, json: JSON) -> CKRecord {
        var record: CKRecord
        if let recordName = json["recordID"].string {
            let recordId = CKRecordID(recordName: recordName)
            record = CKRecord(recordType: entityName, recordID: recordId)
        } else {
            record = CKRecord(recordType: entityName)
        }
        return record
    }
    
    fileprivate func dispatchCompletionHandler(_ handler: @escaping (Bool, NSError?) -> Void, success: Bool, error: NSError?) -> Void {
        DispatchQueue.main.async { handler(success, error) }
    }
    
}
