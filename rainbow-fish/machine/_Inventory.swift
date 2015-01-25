// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Inventory.swift instead.

import CoreData

enum InventoryAttributes: String {
    case quantity = "quantity"
}

enum InventoryRelationships: String {
    case pencil = "pencil"
}

@objc
class _Inventory: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Inventory"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Inventory.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var quantity: NSNumber?

    // func validateQuantity(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var pencil: Pencil?

    // func validatePencil(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

