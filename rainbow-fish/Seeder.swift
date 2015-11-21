//
//  Seeder.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/28/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit
import CloudKit
import SwiftyJSON

enum SeedError: ErrorType {
    case Error(message : String)
}

class Seeder {
    
    private let seedFile = "master.json"
    private let seedDataSubdir = "StartupData"
    private let container: CKContainer
    private let publicDb: CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDb = container.publicCloudDatabase
    }

    func seedPencilDatabase(completion: (success: Bool, message: String?) -> ()) throws  {
        
        let seedURL = NSBundle.mainBundle().URLForResource("master.json", withExtension: nil, subdirectory: self.seedDataSubdir)
        assert(seedURL != nil, "can't find seed json file")
        
        var recordOperations: [CKModifyRecordsOperation] = []
        guard let seedJsonData = NSData(contentsOfURL: seedURL!)  else {
            assertionFailure("Unable to read master json database")
            throw SeedError.Error(message: "Unable to read master json database")
        }
        
        let jsonData = JSON(data: seedJsonData)
        
        for (mfgKey, prodLineJson):(String, JSON) in jsonData {
            
            let mfg = self.manufacturerWithName(mfgKey)
            var changeSet = [mfg]
            
            for (prodLineKey, pencilFilename):(String, JSON) in prodLineJson {
                
                let product = self.productWithName(prodLineKey, manufacturer: mfg)
                changeSet.append(product)

                guard let pencilDataURL = NSBundle.mainBundle().URLForResource(pencilFilename.stringValue, withExtension: nil, subdirectory: self.seedDataSubdir) else {
                    assertionFailure("Missing file \(pencilFilename.stringValue) for \(prodLineKey)")
                    throw SeedError.Error(message: "Missing file \(pencilFilename.stringValue) for \(prodLineKey)")
                }
                guard let pencilData = NSData(contentsOfURL: pencilDataURL) else {
                    assertionFailure("Unable to get pencil json data")
                    throw SeedError.Error(message: "Unable to get pencil json data")
                }
                let pencilJson = JSON(data: pencilData)
                let pencilRecords = self.pencilRecordsFromJson(pencilJson, forProduct: product)
                
                changeSet.appendContentsOf(pencilRecords)
            }
            
            let saveOp = CKModifyRecordsOperation(recordsToSave: changeSet, recordIDsToDelete: nil)
            saveOp.database = self.publicDb
            saveOp.modifyRecordsCompletionBlock = { (records:[CKRecord]?, deletedIds:[CKRecordID]?, error: NSError?) in
                print("Finished with manufacturer: \(mfgKey)")
            }
            saveOp.savePolicy = .AllKeys
            recordOperations.append(saveOp)
            
        }
        guard let lastOp = recordOperations.last else {
            completion(success: false, message: "No records to seed")
            return
        }
        lastOp.modifyRecordsCompletionBlock = { (records:[CKRecord]?, deletedIds:[CKRecordID]?, error: NSError?) in
            completion(success: true, message: nil)
        }
        
        for saveOp in recordOperations {
            if saveOp != lastOp {
                lastOp.addDependency(saveOp)
                saveOp.start()
            }
        }
        lastOp.start()
    }
    
    func manufacturerWithName(name: String) -> CKRecord {
        let manufacturer = CKRecord(recordType: Manufacturer.entityName)
        manufacturer.setObject(name, forKey: ManufacturerAttributes.name.rawValue)
        return manufacturer
    }
    
    func productWithName(name: String, manufacturer: CKRecord) -> CKRecord {
        let product = CKRecord(recordType: Product.entityName)
        product.setObject(name, forKey: ProductAttributes.name.rawValue)
        
        let manufactRef = CKReference(record: manufacturer, action: CKReferenceAction.DeleteSelf)
        product.setObject(manufactRef, forKey: ProductRelationships.manufacturer.rawValue);
        return product
    }
    
    func pencilRecordsFromJson(pencilJson: JSON, forProduct product: CKRecord) -> [CKRecord] {
        let pencilRecords = pencilJson.map { (_:String, json:JSON) -> CKRecord in
            let pencil = CKRecord(recordType: Pencil.entityName)
            pencil.setObject(json[PencilAttributes.name.rawValue].stringValue, forKey: PencilAttributes.name.rawValue)
            pencil.setObject(json[PencilAttributes.identifier.rawValue].stringValue, forKey: PencilAttributes.identifier.rawValue)
            pencil.setObject(json[PencilAttributes.color.rawValue].stringValue, forKey: PencilAttributes.color.rawValue)
            let productRef = CKReference(record: product, action: .DeleteSelf)
            pencil.setObject(productRef, forKey: PencilRelationships.product.rawValue)
            return pencil
        }
        return pencilRecords
    }
    
    func pencilsWithInfo(pencilInfo: [[String:String]], forProduct product: CKRecord) -> [CKRecord] {
        let pencilRecords = pencilInfo.map{ (p: [String:String]) -> CKRecord in
            let pencil = CKRecord(recordType: Pencil.entityName)
            pencil.setObject(p[PencilAttributes.name.rawValue], forKey: PencilAttributes.name.rawValue)
            pencil.setObject(p[PencilAttributes.identifier.rawValue], forKey: PencilAttributes.identifier.rawValue)
            let productRef = CKReference(record: product, action: .DeleteSelf)
            pencil.setObject(productRef, forKey: PencilRelationships.product.rawValue)
            return pencil
        }
        return pencilRecords

    }
    

    
    
}