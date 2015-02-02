
import CoreData
import CoreDataKit
import CloudKit

@objc(Manufacturer)
class Manufacturer: _Manufacturer, CloudSyncable, NamedManagedObject {

    // MARK: NSManagedObject overrides

    override func awakeFromInsert() {
        self.isNew = true
        super.awakeFromInsert()
    }

    
    // MARK: NamedManagedObject
    class var entityName: String { return self.entityName() }

    // MARK: CloudSyncable
    
    func populateFromCKRecord(record: CKRecord) {
        self.recordID = record.recordID.recordName
        self.modificationDate = record.modificationDate
        self.name = record.objectForKey(ManufacturerAttributes.name.rawValue) as? String
    }
    
}
