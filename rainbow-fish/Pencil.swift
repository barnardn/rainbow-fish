import CoreDataKit

@objc(Pencil)
class Pencil: _Pencil, /*CloudSyncable, */NamedManagedObject {

    // MARK: NSManagedObject overrides
    
    override func awakeFromInsert() {
        self.isNew = true
        super.awakeFromInsert()
    }
    
    // MARK: NamedManagedObject    
    
    class var entityName: String { return self.entityName() }
    

    
    
}
