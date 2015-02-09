import CloudKit
import CoreData
import CoreDataKit

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
}

extension Pencil {
    
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
    
}