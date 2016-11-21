import CloudKit
import CoreDataKit


@objc(Product)
open class Product: _Product, NamedManagedObject {
    
    // MARK: NSManagedObject overrides
    
    override open func awakeFromInsert() {
        super.awakeFromInsert()
        self.isNew = true
    }
    
    class var UpdateIntervalInSeconds: TimeInterval { return 60.0 * 60.0 }
    
    open class var entityName : String {
        return self.entityName()
    }
    
}

extension Product: CloudSyncable {
  
    func populateFromCKRecord(_ record: CKRecord) {
        self.recordID = record.recordID.recordName
        self.name = record.object(forKey: ProductAttributes.name.rawValue) as? String
        self.modificationDate = record.modificationDate
        self.ownerRecordIdentifier = record.object(forKey: ProductAttributes.ownerRecordIdentifier.rawValue) as? String
    }

    func toCKRecord() -> CKRecord {
        var record: CKRecord
        if let recordID = self.recordID {
            let ckRecordID = CKRecordID(recordName: recordID)
            record = CKRecord(recordType: Product.entityName, recordID: ckRecordID) as CKRecord
        } else {
            record = CKRecord(recordType: Product.entityName)
        }
        record.setValue(self.ownerRecordIdentifier, forKey: ProductAttributes.ownerRecordIdentifier.rawValue)
        record.setValue(self.name, forKey: ProductAttributes.name.rawValue)
        return record
    }
    
    func toJson(_ includeRelationships: Bool = false ) -> NSDictionary {

        let jsonObject = NSMutableDictionary()
        jsonObject[ProductAttributes.recordID.rawValue] = self.recordID
        jsonObject[ProductAttributes.name.rawValue] = self.name
        jsonObject[ProductAttributes.modificationDate.rawValue] = self.modificationDate?.timeIntervalSince1970
        jsonObject[ProductAttributes.ownerRecordIdentifier.rawValue] = self.ownerRecordIdentifier
        
        if includeRelationships {
            var pencilJson = [NSDictionary]()
            if let pencils = self.pencils.allObjects as? [Pencil] {
                for pencil in pencils {
                    pencilJson.append(pencil.toJson())
                }
            }
            jsonObject[ProductRelationships.pencils.rawValue] = pencilJson
        }
        return jsonObject
    }
    
    
}

extension Product {
    
    var shouldPerformUpdate: Bool {
        get {
            if let lastSyncDate = self.syncInfo?.lastRefreshTime {
                let updateTime = Date(timeInterval: Product.UpdateIntervalInSeconds, since: lastSyncDate as Date)
                let now = Date()
                return (now.timeIntervalSince(updateTime) >= 0.0)
            }
            return true
        }
    }
    
    func sortedPencils() -> [Pencil]? {
        if let pencils = self.pencils.allObjects as? [Pencil] {
            return pencils.sorted(by: { (p1: Pencil, p2: Pencil) -> Bool in
                let name1 = p1.name as String!
                let name2 = p2.name as String!
                return (name1!.localizedCaseInsensitiveCompare(name2!) == .orderedDescending)
            })
        }
        return nil
    }
    
    func ckReferenceWithManufacturerRecord(_ manufacturerRecord: CKRecord) -> CKReference {
        let reference = CKReference(record: manufacturerRecord, action: .deleteSelf)
        let productRecord = self.toCKRecord()
        reference.setValue(productRecord, forKey: ProductRelationships.manufacturer.rawValue)
        return reference
    }

}
