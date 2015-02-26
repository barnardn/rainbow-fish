import CloudKit
import CoreData
import CoreDataKit
import UIKit

@objc(Pencil)
class Pencil: _Pencil, NamedManagedObject {

    // MARK: NSManagedObject overrides
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.isNew = true
    }

    override func awakeFromFetch() {
        super.awakeFromFetch()
        self.isNew = false
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
    
    func toCKRecord() -> CKRecord {
        let ckRecordID = CKRecordID(recordName: self.recordID!)
        let record = CKRecord(recordType: Pencil.entityName, recordID: ckRecordID)
        record.setValue(self.name, forKey: PencilAttributes.name.rawValue)
        record.setValue(self.identifier, forKey: PencilAttributes.identifier.rawValue)
        if let color = self.color as? UIColor {
            record.setValue(color.rgbRepresentation, forKey: PencilAttributes.color.rawValue)
        }
        return record
    }
    
}

extension Pencil {
    
    // MARK: core data methods
    
    class func allPencils(forProduct product: Product,  context: NSManagedObjectContext) -> [Pencil]? {
        let predicate = NSPredicate(format: "%K == %@", PencilRelationships.product.rawValue, product)
        let byName = NSSortDescriptor(key: PencilAttributes.name.rawValue, ascending: true)
        switch context.find(Pencil.self, predicate: predicate, sortDescriptors: [byName], limit: nil, offset: nil) {
        case let .Failure(error):
            assertionFailure(error.localizedDescription)
        case let .Success(boxedResults):
            return boxedResults()
        }
    }
    
    // MARK: cloud kit methods
    
    func ckReferenceWithProductRecord(productRecord: CKRecord) -> CKReference {
        let reference = CKReference(record: productRecord, action: .DeleteSelf)
        let pencilRecord = self.toCKRecord()
        reference.setValue(pencilRecord, forKey: PencilRelationships.product.rawValue)
        return reference
    }
    
}