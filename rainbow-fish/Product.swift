import CloudKit
import CoreDataKit


@objc(Product)
class Product: _Product, NamedManagedObject {
    
    // MARK: NSManagedObject overrides
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.isNew = true
    }
    
    // MARK: NamedManagedObject
    class var entityName: String { return self.entityName() }
    class var UpdateIntervalInSeconds: NSTimeInterval { return 60.0 * 60.0 }
}

extension Product: CloudSyncable {
  
    func populateFromCKRecord(record: CKRecord) {
        self.recordID = record.recordID.recordName
        self.name = record.objectForKey(ProductAttributes.name.rawValue) as? String
        self.modificationDate = record.modificationDate
    }

    func toCKRecord() -> CKRecord {
        var record: CKRecord
        if let recordID = self.recordID {
            let ckRecordID = CKRecordID(recordName: recordID)
            record = CKRecord(recordType: Product.entityName, recordID: ckRecordID) as CKRecord
        } else {
            record = CKRecord(recordType: Product.entityName)
        }
        record.setValue(self.name, forKey: ProductAttributes.name.rawValue)
        return record
    }
    
}

extension Product {
    
    var shouldPerformUpdate: Bool {
        get {
            if let lastSyncDate = self.syncInfo?.lastRefreshTime {
                let updateTime = NSDate(timeInterval: Product.UpdateIntervalInSeconds, sinceDate: lastSyncDate)
                let now = NSDate()
                return (now.timeIntervalSinceDate(updateTime) >= 0.0)
            }
            return true
        }
    }
    
    func sortedPencils() -> [Pencil]? {
        if let pencils = self.pencils.allObjects as? [Pencil] {
            return pencils.sorted({ (p1: Pencil, p2: Pencil) -> Bool in
                let name1 = p1.name as String!
                let name2 = p2.name as String!
                return (name1.localizedCaseInsensitiveCompare(name2) == .OrderedDescending)
            })
        }
        return nil
    }
    
    func ckReferenceWithManufacturerRecord(manufacturerRecord: CKRecord) -> CKReference {
        let reference = CKReference(record: manufacturerRecord, action: .DeleteSelf)
        let productRecord = self.toCKRecord()
        reference.setValue(productRecord, forKey: ProductRelationships.manufacturer.rawValue)
        return reference
    }

}
