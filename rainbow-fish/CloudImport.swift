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
    private let container: CKContainer
    private let publicDb: CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDb = container.publicCloudDatabase
    }

    func seedToCloud (completionHandler: (success: Bool, error: NSError?) -> Void) -> Void {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] () -> Void in
         
            let databaseUrl = AppController.appController.urlForResourceInApplicationSupport(resourceName: self.ImportFilename)
            let jsonData = NSData(contentsOfURL: databaseUrl)
            var readError: NSError?
            let databaseJSON = JSON(data: jsonData!, error: &readError)
            if let err = readError {
                self.dispatchCompletionHandler(completionHandler, success: false, error: err)
                return
            }
            
            let modifyOperations = databaseJSON.arrayValue.map{ [unowned self] (mfgJSON: JSON) -> CKModifyRecordsOperation in
                let records = self.mfgTree(mfgJSON)
                let mop =  CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                mop.savePolicy = .AllKeys
                return mop
            }
            let lastOp = modifyOperations.last!
            lastOp.modifyRecordsCompletionBlock = { [unowned self] (saved, deleted, error) in
                if let err = error {
                    self.dispatchCompletionHandler(completionHandler, success: false, error: err)
                } else {
                    self.dispatchCompletionHandler(completionHandler, success: true, error: nil)
                }
            }
            for mop in modifyOperations {
                if mop != lastOp {
                    lastOp.addDependency(mop)
                }
                self.publicDb.addOperation(mop)
            }
        }
    }
    
    private func mfgTree(json: JSON) -> [CKRecord] {
        
        var accumulator = [CKRecord]()

        var mfgRec = self.createCKRecord(Manufacturer.entityName(), json: json)
        mfgRec.setValue(json[ManufacturerAttributes.name.rawValue].string, forKey: ManufacturerAttributes.name.rawValue)
        accumulator.append(mfgRec)
        if let products = json[ManufacturerRelationships.products.rawValue].array {
            let productRecords = self.productTree(productJSON: products, mfg: mfgRec)
            accumulator += productRecords
        }
        return accumulator
    }
    
    private func productTree(#productJSON: [JSON], mfg: CKRecord) -> [CKRecord] {
        
        var accumulator = [CKRecord]()
        
        for json in productJSON {
            var prodRec = self.createCKRecord(Product.entityName(), json: json)
            prodRec.setValue(json[ProductAttributes.name.rawValue].string, forKey: ProductAttributes.name.rawValue)
            let mfgRelation = CKReference(record: mfg, action: .DeleteSelf)
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
    
    private func pencils(#pencilJSON: [JSON], product: CKRecord) -> [CKRecord] {
        
        return pencilJSON.map{ (json: JSON) -> CKRecord in
            var pencilRec = self.createCKRecord(Pencil.entityName(), json: json)
            pencilRec.setValue(json[PencilAttributes.name.rawValue].string, forKey: PencilAttributes.name.rawValue)
            pencilRec.setValue(json[PencilAttributes.identifier.rawValue].string, forKey: PencilAttributes.identifier.rawValue)
            pencilRec.setValue(json[PencilAttributes.color.rawValue].string, forKey: PencilAttributes.color.rawValue)
            let prodRelation = CKReference(record: product, action: .DeleteSelf)
            pencilRec.setObject(prodRelation, forKey: PencilRelationships.product.rawValue)
            return pencilRec
        }
    }
    
    private func createCKRecord(entityName: String, json: JSON) -> CKRecord {
        var record: CKRecord
        if let recordName = json["recordID"].string {
            let recordId = CKRecordID(recordName: recordName)
            record = CKRecord(recordType: entityName, recordID: recordId)
        } else {
            record = CKRecord(recordType: entityName)
        }
        return record
    }
    
    private func dispatchCompletionHandler(handler: (Bool, NSError?) -> Void, success: Bool, error: NSError?) -> Void {
        dispatch_async(dispatch_get_main_queue()) { handler(success, error) }
    }
    
}