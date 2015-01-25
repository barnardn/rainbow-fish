// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Pencil.swift instead.

import CoreData

enum PencilAttributes: String {
    case color = "color"
    case identifier = "identifier"
    case name = "name"
}

enum PencilRelationships: String {
    case inventory = "inventory"
    case product = "product"
}

@objc
class _Pencil: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Pencil"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Pencil.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var color: AnyObject?

    // func validateColor(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var identifier: String

    // func validateIdentifier(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var inventory: Inventory?

    // func validateInventory(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var product: Product?

    // func validateProduct(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

