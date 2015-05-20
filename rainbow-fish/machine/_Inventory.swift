// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Inventory.swift instead.

import CoreData

enum InventoryAttributes: String {
    case color = "color"
    case identity = "identity"
    case manufacturerName = "manufacturerName"
    case name = "name"
    case pencilIdentifier = "pencilIdentifier"
    case productName = "productName"
    case quantity = "quantity"
}

enum InventoryRelationships: String {
    case pencil = "pencil"
}

@objc
class _Inventory: NSManagedObject {

    // MARK: - Class methods

    class var entityName : String {
        return "Inventory"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: managedObjectContext);
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
    var color: AnyObject?

    // func validateColor(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var identity: String?

    // func validateIdentity(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var manufacturerName: String?

    // func validateManufacturerName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var pencilIdentifier: String?

    // func validatePencilIdentifier(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var productName: String?

    // func validateProductName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var quantity: NSDecimalNumber?

    // func validateQuantity(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var pencil: Pencil?

    // func validatePencil(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

