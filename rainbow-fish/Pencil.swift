import CloudKit
import CoreDataKit

@objc(Pencil)
class Pencil: _Pencil, NamedManagedObject {

    // MARK: NSManagedObject overrides
    
    override func awakeFromInsert() {
        self.isNew = true
        super.awakeFromInsert()
    }
    
    // MARK: NamedManagedObject    
    
    class var entityName: String { return self.entityName() }
    
}

extension Pencil: CloudSyncable {
    
    func populateFromCKRecord(record: CKRecord) {
        self.recordID = record.recordID.recordName
        self.color = record.objectForKey(PencilAttributes.color.rawValue)
        self.modificationDate = record.modificationDate
        self.name = record.objectForKey(PencilAttributes.name.rawValue) as? String
        self.identifier = record.objectForKey(PencilAttributes.identifier.rawValue) as String
    }
    
}