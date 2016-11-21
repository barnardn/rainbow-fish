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

enum SeedError: Error {
    case error(message : String)
}

class Seeder {
    
    fileprivate let seedFile = "master.json"
    fileprivate let seedDataSubdir = "StartupData"
    fileprivate let container: CKContainer
    fileprivate let publicDb: CKDatabase
    
    init() {
        container = CKContainer.default()
        publicDb = container.publicCloudDatabase
    }

    func createCloudkitCatalog(_ progress: @escaping (_ success: Bool, _ message: String?) -> Void, completion: @escaping (_ success: Bool, _ message: String?) -> Void) throws {
        
        let seedURL = Bundle.main.url(forResource: "master.json", withExtension: nil, subdirectory: self.seedDataSubdir)
        assert(seedURL != nil, "can't find seed json file")
        
        var recordOperations: [CKModifyRecordsOperation] = []
        guard let seedJsonData = try? Data(contentsOf: seedURL!)  else {
            assertionFailure("Unable to read master json database")
            throw SeedError.error(message: "Unable to read master json database")
        }
        
        let jsonData = JSON(data: seedJsonData)
        
        for (mfgKey, prodLineJson):(String, JSON) in jsonData {
            
            let mfg = self.manufacturerWithName(mfgKey)
            var changeSet = [mfg]
            
            for (prodLineKey, pencilFilename):(String, JSON) in prodLineJson {
                
                let product = self.productWithName(prodLineKey, manufacturer: mfg)
                changeSet.append(product)

                guard let pencilDataURL = Bundle.main.url(forResource: pencilFilename.stringValue, withExtension: nil, subdirectory: self.seedDataSubdir) else {
                    assertionFailure("Missing file \(pencilFilename.stringValue) for \(prodLineKey)")
                    throw SeedError.error(message: "Missing file \(pencilFilename.stringValue) for \(prodLineKey)")
                }
                
                guard let pencilData = try? Data(contentsOf: pencilDataURL) else {
                    assertionFailure("Unable to get pencil json data")
                    throw SeedError.error(message: "Unable to get pencil json data")
                }
                
                let pencilJson = JSON(data: pencilData)
                let pencilRecords = self.pencilRecordsFromJson(pencilJson, forProduct: product)
                
                changeSet.append(contentsOf: pencilRecords)
            }
            
            let saveOp = CKModifyRecordsOperation(recordsToSave: changeSet, recordIDsToDelete: nil)
            saveOp.database = self.publicDb
            saveOp.modifyRecordsCompletionBlock = { (records , deletedIds , error) in
                if let error = error {
                    print(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        progress(false, "\(mfgKey) ✕")
                    }

                } else {
                    
                    DispatchQueue.main.async {
                        progress(true, "\(mfgKey) ✓")
                    }
                    
                }

            }
            saveOp.savePolicy = .allKeys
            recordOperations.append(saveOp)
            
        }
        guard let lastOp = recordOperations.last else {
            completion(false, "No records to seed")
            return
        }

        lastOp.completionBlock = {
            DispatchQueue.main.async(execute: { () -> Void in
                completion(true, "Cloud catalog creation complete!")
            })
        }
        
        for saveOp in recordOperations {
            if saveOp != lastOp {
                lastOp.addDependency(saveOp)
                self.publicDb.add(saveOp)
            }
        }
        self.publicDb.add(lastOp)
    }
    
    func manufacturerWithName(_ name: String) -> CKRecord {
        let manufacturer = CKRecord(recordType: Manufacturer.entityName)
        manufacturer.setObject(name as CKRecordValue?, forKey: ManufacturerAttributes.name.rawValue)
        return manufacturer
    }
    
    func productWithName(_ name: String, manufacturer: CKRecord) -> CKRecord {
        let product = CKRecord(recordType: Product.entityName)
        product.setObject(name as CKRecordValue?, forKey: ProductAttributes.name.rawValue)
        
        let manufactRef = CKReference(record: manufacturer, action: CKReferenceAction.deleteSelf)
        product.setObject(manufactRef, forKey: ProductRelationships.manufacturer.rawValue);
        return product
    }
    
    func pencilRecordsFromJson(_ pencilJson: JSON, forProduct product: CKRecord) -> [CKRecord] {
        let pencilRecords = pencilJson.map { (_:String, json:JSON) -> CKRecord in
            let pencil = CKRecord(recordType: Pencil.entityName)

            if  let name = json[PencilAttributes.name.rawValue].stringValue as CKRecordValue?,
                let identifier = json[PencilAttributes.identifier.rawValue].stringValue as CKRecordValue?,
                let color = json[PencilAttributes.color.rawValue].stringValue as CKRecordValue?
            {
                pencil.setObject(name, forKey: PencilAttributes.name.rawValue)
                pencil.setObject(identifier, forKey: PencilAttributes.identifier.rawValue)
                pencil.setObject(color, forKey: PencilAttributes.color.rawValue)
            }
            let productRef = CKReference(record: product, action: .deleteSelf)
            pencil.setObject(productRef, forKey: PencilRelationships.product.rawValue)
            return pencil
        }
        return pencilRecords
    }
    
    func pencilsWithInfo(_ pencilInfo: [[String:String]], forProduct product: CKRecord) -> [CKRecord] {
        let pencilRecords = pencilInfo.map{ (p: [String:String]) -> CKRecord in
            let pencil = CKRecord(recordType: Pencil.entityName)
            pencil.setObject(p[PencilAttributes.name.rawValue] as CKRecordValue?, forKey: PencilAttributes.name.rawValue)
            pencil.setObject(p[PencilAttributes.identifier.rawValue] as CKRecordValue?, forKey: PencilAttributes.identifier.rawValue)
            let productRef = CKReference(record: product, action: .deleteSelf)
            pencil.setObject(productRef, forKey: PencilRelationships.product.rawValue)
            return pencil
        }
        return pencilRecords

    }
    

    
    
}
