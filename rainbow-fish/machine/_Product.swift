// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Product.swift instead.

import CoreData

enum ProductAttributes: String {
    case isNew = "isNew"
    case modificationDate = "modificationDate"
    case name = "name"
    case ownerRecordIdentifer = "ownerRecordIdentifer"
    case recordID = "recordID"
}

enum ProductRelationships: String {
    case manufacturer = "manufacturer"
    case pencils = "pencils"
    case syncInfo = "syncInfo"
}

@objc
class _Product: NSManagedObject {

    // MARK: - Class methods

    class var entityName : String {
        return "Product"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Product.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var isNew: NSNumber?

    // func validateIsNew(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var modificationDate: NSDate?

    // func validateModificationDate(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var ownerRecordIdentifer: String?

    // func validateOwnerRecordIdentifer(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var recordID: String?

    // func validateRecordID(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var manufacturer: Manufacturer?

    // func validateManufacturer(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var pencils: NSSet

    @NSManaged
    var syncInfo: SyncInfo?

    // func validateSyncInfo(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _Product {

    func addPencils(objects: NSSet) {
        let mutable = self.pencils.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.pencils = mutable.copy() as! NSSet
    }

    func removePencils(objects: NSSet) {
        let mutable = self.pencils.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.pencils = mutable.copy() as! NSSet
    }

    func addPencilsObject(value: Pencil!) {
        let mutable = self.pencils.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.pencils = mutable.copy() as! NSSet
    }

    func removePencilsObject(value: Pencil!) {
        let mutable = self.pencils.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.pencils = mutable.copy() as! NSSet
    }

}
