
import CoreData
import CoreDataKit
import CloudKit

@objc(Manufacturer)
class Manufacturer: _Manufacturer, CloudSyncable, NamedManagedObject {

    func sayHi() {
        println("\(self.name) says Hi!")
    }
    
    func sortedProducts() -> [Product]? {
        if let products = self.products.allObjects as? [Product] {
            products.sorted{(p1: Product, p2: Product) in
                let name1 = p1.name as String!
                let name2 = p2.name as String!
                return ((name1.localizedCaseInsensitiveCompare(name2)) == .OrderedDescending)
            }
        }
        return nil
    }
    
    // MARK: NSManagedObject overrides

    override func awakeFromInsert() {
        self.isNew = true
        super.awakeFromInsert()
    }

    override func awakeFromFetch() {
        super.awakeFromFetch()
        println("hmm....")
        self.sayHi()
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
