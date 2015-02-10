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

extension Product {
    
    func sortedPencils() -> [Pencil]? {
        if let pencils = self.pencils.allObjects as? [Pencil] {
            return pencils.sorted({ (p1: Pencil, p2: Pencil) -> Bool in
                let name1 = p1.name as String!
                let name2 = p2.name as String!
                return (name1.localizedCaseInsensitiveCompare(name2) == .OrderedDescending)
            })
        }
        return nil
    }
    

    
}
