// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Inventory.swift instead.

import Foundation
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

open class _Inventory: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Inventory"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Inventory.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var color: AnyObject?

    @NSManaged open
    var manufacturerName: String?

    @NSManaged open
    var name: String?

    @NSManaged open
    var ownerRecordIdentifier: String?

    @NSManaged open
    var pencilIdentifier: String?

    @NSManaged open
    var productName: String?

    @NSManaged open
    var quantity: NSDecimalNumber?

    @NSManaged open
    var recordID: String?

    // MARK: - Relationships

    @NSManaged open
    var pencil: Pencil?

}

