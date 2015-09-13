import CloudKit
import CoreData
import CoreDataKit
import UIKit

@objc(Pencil)
public class Pencil: _Pencil, NamedManagedObject {

    // MARK: NSManagedObject overrides
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.isNew = true
    }

    override public func awakeFromFetch() {
        super.awakeFromFetch()
        self.isNew = false
    }
    
    public class var entityName : String {
        return self.mogen_entityName()
    }
    
}

extension Pencil: CloudSyncable {
    
    func populateFromCKRecord(record: CKRecord) {
        self.recordID = record.recordID.recordName
        if let colorValue = record.objectForKey(PencilAttributes.color.rawValue) as? String {
            self.color = UIColor.colorFromRGBString(colorValue)
        }
        self.modificationDate = record.modificationDate
        self.name = record.objectForKey(PencilAttributes.name.rawValue) as? String
        self.identifier = record.objectForKey(PencilAttributes.identifier.rawValue) as? String
        self.ownerRecordIdentifier = record.objectForKey(PencilAttributes.ownerRecordIdentifier.rawValue) as? String
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
    
    func toJson(includeRelationships: Bool = false ) -> NSDictionary {
        
        var jsonObject = NSMutableDictionary()
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
    
    class func allPencils(forProduct product: Product,  context: NSManagedObjectContext) -> [Pencil]? {
        let predicate = NSPredicate(format: "%K == %@", PencilRelationships.product.rawValue, product)
        let byName = NSSortDescriptor(key: PencilAttributes.name.rawValue, ascending: true)
        switch context.find(Pencil.self, predicate: predicate, sortDescriptors: [byName], limit: nil, offset: nil) {
        case let .Failure(error):
            assertionFailure(error.localizedDescription)
        case let .Success(boxedResults):
            return boxedResults.value
        }
        return nil
    }
    
    func canSave() -> Bool {
        if let identifierLength = self.identifier?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
            if let nameLength = self.name?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
                return (identifierLength > 0 && nameLength > 0)
            }
        }
        return false
    }
    
    func isMyPencil() -> Bool {
        if let pencilOwnerId = self.ownerRecordIdentifier {
            if let ownerId = AppController.appController.appConfiguration.iCloudRecordID {
                return pencilOwnerId == ownerId
            }
        }
        return false
    }
    
    // MARK: cloud kit methods
    
    func ckReferenceWithProductRecord(productRecord: CKRecord) -> CKReference {
        let reference = CKReference(record: productRecord, action: .DeleteSelf)
        let pencilRecord = self.toCKRecord()
        pencilRecord.setValue(reference, forKey: PencilRelationships.product.rawValue)
        return reference
    }
    
}