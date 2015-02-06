import CloudKit
import CoreDataKit


@objc(Product)
class Product: _Product, NamedManagedObject {
    
    // MARK: NSManagedObject overrides
    
    override func awakeFromInsert() {
        self.isNew = true
        super.awakeFromInsert()
    }
    
    // MARK: NamedManagedObject
    class var entityName: String { return self.entityName() }

}

extension Product: CloudSyncable {
  
    func populateFromCKRecord(record: CKRecord) {
        self.recordID = record.recordID.recordName
        self.name = record.objectForKey(ProductAttributes.name.rawValue) as? String
        self.modificationDate = record.modificationDate
    }

}