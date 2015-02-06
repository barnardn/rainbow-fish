
import CoreData
import CoreDataKit
import CloudKit

@objc(Manufacturer)
class Manufacturer: _Manufacturer, NamedManagedObject {
    
    // MARK: NSManagedObject overrides

    override func awakeFromInsert() {
        self.isNew = true
        super.awakeFromInsert()
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
    }
    
}



extension Manufacturer {
    
    func sayHi() -> Void {
        println("\(self.name) says Hi!")
    }
    
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