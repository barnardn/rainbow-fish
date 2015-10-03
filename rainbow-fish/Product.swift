import CloudKit
import CoreDataKit


@objc(Product)
public class Product: _Product, NamedManagedObject {
    
    // MARK: NSManagedObject overrides
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.isNew = true
    }
    
    class var UpdateIntervalInSeconds: NSTimeInterval { return 60.0 * 60.0 }
    
    public class var entityName : String {
        return self.mogen_entityName()
    }
    
}

extension Product: CloudSyncable {
  
    func populateFromCKRecord(record: CKRecord) {
        self.recordID = record.recordID.recordName
        self.name = record.objectForKey(ProductAttributes.name.rawValue) as? String
        self.modificationDate = record.modificationDate
        self.ownerRecordIdentifier = record.objectForKey(ProductAttributes.ownerRecordIdentifier.rawValue) as? String
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
    
    func toJson(includeRelationships: Bool = false ) -> NSDictionary {

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
                let updateTime = NSDate(timeInterval: Product.UpdateIntervalInSeconds, sinceDate: lastSyncDate)
                let now = NSDate()
                return (now.timeIntervalSinceDate(updateTime) >= 0.0)
            }
            return true
        }
    }
    
    func sortedPencils() -> [Pencil]? {
        if let pencils = self.pencils.allObjects as? [Pencil] {
            return pencils.sort({ (p1: Pencil, p2: Pencil) -> Bool in
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
