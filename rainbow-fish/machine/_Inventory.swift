// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Inventory.swift instead.

/*

	_Inventory.swift

	Generated by mogenerator
	Copyright (c) 2015 Norm Barnard

*/

import CoreData

public enum InventoryAttributes: String {
    case color = "color"
    case manufacturerName = "manufacturerName"
    case name = "name"
    case ownerRecordIdentifier = "ownerRecordIdentifier"
    case pencilIdentifier = "pencilIdentifier"
    case productName = "productName"
    case quantity = "quantity"
    case recordID = "recordID"
}

public enum InventoryRelationships: String {
    case pencil = "pencil"
}

@objc public
class _Inventory: NSManagedObject {

    // MARK: - Class methods

	public class func mogen_entityName () -> String {
        return "Inventory"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.mogen_entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Inventory.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var color: AnyObject?

    // func validateColor(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var manufacturerName: String?

    // func validateManufacturerName(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var name: String?

    // func validateName(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var ownerRecordIdentifier: String?

    // func validateOwnerRecordIdentifier(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var pencilIdentifier: String?

    // func validatePencilIdentifier(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var productName: String?

    // func validateProductName(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var quantity: NSDecimalNumber?

    // func validateQuantity(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var recordID: String?

    // func validateRecordID(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var pencil: Pencil?

    // func validatePencil(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

}

