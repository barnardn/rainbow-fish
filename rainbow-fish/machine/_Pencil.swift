// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Pencil.swift instead.

import Foundation
import CoreData

public enum PencilAttributes: String {
    case color = "color"
    case identifier = "identifier"
    case isNew = "isNew"
    case modificationDate = "modificationDate"
    case name = "name"
    case ownerRecordIdentifier = "ownerRecordIdentifier"
    case recordID = "recordID"
}

public enum PencilRelationships: String {
    case inventory = "inventory"
    case product = "product"
}

open class _Pencil: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Pencil"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Pencil.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var color: AnyObject?

    @NSManaged open
    var identifier: String?

    @NSManaged open
    var isNew: NSNumber?

    @NSManaged open
    var modificationDate: Date?

    @NSManaged open
    var name: String?

    @NSManaged open
    var ownerRecordIdentifier: String?

    @NSManaged open
    var recordID: String?

    // MARK: - Relationships

    @NSManaged open
    var inventory: Inventory?

    @NSManaged open
    var product: Product?

}

