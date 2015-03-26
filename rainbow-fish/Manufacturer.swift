
import CoreData
import CoreDataKit
import CloudKit

@objc(Manufacturer)
class Manufacturer: _Manufacturer, NamedManagedObject {
    
    // MARK: NSManagedObject overrides

    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.isNew = true
    }
    
    // MARK: NamedManagedObject
    class var entityName: String { return self.entityName() }

    // MARK: CloudSyncable
}

extension Manufacturer: CloudSyncable {
   
    func populateFromCKRecord(record: CKRecord) {
        self.recordID = record.recordID.recordName
        self.modificationDate = record.modificationDate
        self.name = record.objectForKey(ManufacturerAttributes.name.rawValue) as? String
        self.ownerRecordIdentifer = record.creatorUserRecordID.recordName
    }
    
    func toCKRecord() -> CKRecord {
        var record: CKRecord
        if let recordID = self.recordID {
            let ckRecordID = CKRecordID(recordName: recordID)
            record = CKRecord(recordType: Manufacturer.entityName, recordID: ckRecordID) as CKRecord
        } else {
            record = CKRecord(recordType: Manufacturer.entityName)
        }
        record.setValue(self.name, forKey: ManufacturerAttributes.name.rawValue)
        return record
    }
    
}

extension Manufacturer {
    
    func sortedProducts() -> [Product]? {
        if let products = self.products.allObjects as? [Product] {
            return products.sorted{(p1: Product, p2: Product) in
                let name1 = p1.name as String!
                let name2 = p2.name as String!
                return ((name1.localizedCaseInsensitiveCompare(name2)) == .OrderedAscending)
            }
        }
        return nil
    }
    
    
}