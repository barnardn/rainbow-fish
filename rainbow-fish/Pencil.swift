import CloudKit
import CoreData
import CoreDataKit
import UIKit

@objc(Pencil)
open class Pencil: _Pencil, NamedManagedObject {

    // MARK: NSManagedObject overrides
    
    override open func awakeFromInsert() {
        super.awakeFromInsert()
        self.isNew = true
    }

    override open func awakeFromFetch() {
        super.awakeFromFetch()
        self.isNew = false
    }
    
    open class var entityName : String {
        return self.entityName()
    }
    
}

extension Pencil: CloudSyncable {
    
    func populateFromCKRecord(_ record: CKRecord) {
        self.recordID = record.recordID.recordName
        if let colorValue = record.object(forKey: PencilAttributes.color.rawValue) as? String {
            self.color = UIColor.colorFromRGBString(colorValue)
        }
        self.modificationDate = record.modificationDate
        self.name = record.object(forKey: PencilAttributes.name.rawValue) as? String
        self.identifier = record.object(forKey: PencilAttributes.identifier.rawValue) as? String
        self.ownerRecordIdentifier = record.object(forKey: PencilAttributes.ownerRecordIdentifier.rawValue) as? String
    }
    
    func toCKRecord() -> CKRecord {
        var record: CKRecord
        if let recordID = self.recordID {
            let ckRecordID = CKRecordID(recordName: recordID)
            record = CKRecord(recordType: Pencil.entityName, recordID: ckRecordID) as CKRecord
        } else {
            record = CKRecord(recordType: Pencil.entityName)
        }
        record.setValue(self.name, forKey: PencilAttributes.name.rawValue)
        record.setValue(self.identifier, forKey: PencilAttributes.identifier.rawValue)
        record.setValue(self.ownerRecordIdentifier, forKey: PencilAttributes.ownerRecordIdentifier.rawValue)
        if let color = self.color as? UIColor {
            record.setValue(color.rgbRepresentation, forKey: PencilAttributes.color.rawValue)
        }
        return record
    }
    
    func toJson(_ includeRelationships: Bool = false ) -> NSDictionary {
        
        let jsonObject = NSMutableDictionary()
        jsonObject[PencilAttributes.recordID.rawValue] = self.recordID
        jsonObject[PencilAttributes.name.rawValue] = self.name
        jsonObject[PencilAttributes.identifier.rawValue] = self.identifier
        if let color = self.color as? UIColor {
            jsonObject[PencilAttributes.color.rawValue] = color.rgbRepresentation
        }
        jsonObject[PencilAttributes.modificationDate.rawValue] = self.modificationDate?.timeIntervalSince1970
        jsonObject[PencilAttributes.ownerRecordIdentifier.rawValue] = self.ownerRecordIdentifier
        return jsonObject
    }
    
}

extension Pencil {
    
    // MARK: core data methods
    
    class func allPencils(forProduct product: Product,  context: NSManagedObjectContext) throws -> [Pencil]? {
        let predicate = NSPredicate(format: "%K == %@", PencilRelationships.product.rawValue, product)
        let byName = NSSortDescriptor(key: PencilAttributes.name.rawValue, ascending: true)
        return try context.find(Pencil.self, predicate: predicate, sortDescriptors: [byName], limit: nil, offset: nil)
    }
    
    func canSave() -> Bool {
        if  let identifierLength = self.identifier?.lengthOfBytes(using: String.Encoding.utf8),
            let nameLength = self.name?.lengthOfBytes(using: String.Encoding.utf8) {
                return (identifierLength > 0 && nameLength > 0)
        }
        return false
    }
    
    func isMyPencil() -> Bool {
        if let pencilOwnerId = self.ownerRecordIdentifier,
           let ownerId = AppController.appController.appConfiguration.iCloudRecordID {
                return pencilOwnerId == ownerId
        }
        return false
    }
    
    // MARK: cloud kit methods
    
    func ckReferenceWithProductRecord(_ productRecord: CKRecord) -> CKReference {
        let reference = CKReference(record: productRecord, action: .deleteSelf)
        let pencilRecord = self.toCKRecord()
        pencilRecord.setValue(reference, forKey: PencilRelationships.product.rawValue)
        return reference
    }
    
}
