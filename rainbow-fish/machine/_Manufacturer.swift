// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Manufacturer.swift instead.

import CoreData

enum ManufacturerAttributes: String {
    case isNew = "isNew"
    case modificationDate = "modificationDate"
    case name = "name"
    case ownerRecordIdentifer = "ownerRecordIdentifer"
    case recordID = "recordID"
}

enum ManufacturerRelationships: String {
    case products = "products"
}

@objc
class _Manufacturer: NSManagedObject {

    // MARK: - Class methods

    class var entityName : String {
        return "Manufacturer"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Manufacturer.entity(managedObjectContext)
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
    var products: NSSet

}

extension _Manufacturer {

    func addProducts(objects: NSSet) {
        let mutable = self.products.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.products = mutable.copy() as! NSSet
    }

    func removeProducts(objects: NSSet) {
        let mutable = self.products.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.products = mutable.copy() as! NSSet
    }

    func addProductsObject(value: Product!) {
        let mutable = self.products.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.products = mutable.copy() as! NSSet
    }

    func removeProductsObject(value: Product!) {
        let mutable = self.products.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.products = mutable.copy() as! NSSet
    }

}
