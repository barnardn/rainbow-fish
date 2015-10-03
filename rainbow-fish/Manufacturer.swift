
import CoreData
import CoreDataKit
import CloudKit

@objc(Manufacturer)
public class Manufacturer: _Manufacturer, NamedManagedObject {
    
    // MARK: NSManagedObject overrides

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.isNew = true
    }
    
    public class var entityName : String {
        return self.mogen_entityName()
    }
    
}

extension Manufacturer: CloudSyncable {
   
    func populateFromCKRecord(record: CKRecord) {
        self.recordID = record.recordID.recordName
        self.modificationDate = record.modificationDate
        self.name = record.objectForKey(ManufacturerAttributes.name.rawValue) as? String
        self.ownerRecordIdentifier = record.objectForKey(ManufacturerAttributes.ownerRecordIdentifier.rawValue) as? String
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
        record.setValue(self.ownerRecordIdentifier, forKey: ManufacturerAttributes.ownerRecordIdentifier.rawValue)
        return record
    }
    
    func toJson(includeRelationships: Bool = false ) -> NSDictionary {
        
        let jsonObject = NSMutableDictionary()
        jsonObject[ManufacturerAttributes.recordID.rawValue] = self.recordID
        jsonObject[ManufacturerAttributes.name.rawValue] = self.name
        jsonObject[ManufacturerAttributes.modificationDate.rawValue] = self.modificationDate?.timeIntervalSince1970
        jsonObject[ManufacturerAttributes.ownerRecordIdentifier.rawValue] = self.ownerRecordIdentifier;
        
        if includeRelationships {
            var productJson = [NSDictionary]()
            if let products = self.products.allObjects as? [Product] {
                for product in products {
                    productJson.append(product.toJson(includeRelationships))
                }
            }
            jsonObject[ManufacturerRelationships.products.rawValue] = productJson
        }
        return jsonObject
    }
    
    
    
}

extension Manufacturer {
    
    func sortedProducts() -> [Product]? {
        if let products = self.products.allObjects as? [Product] {
            return products.sort{(p1: Product, p2: Product) in
                let name1 = p1.name as String!
                let name2 = p2.name as String!
                return ((name1.localizedCaseInsensitiveCompare(name2)) == .OrderedAscending)
            }
        }
        return nil
    }
    
    
}