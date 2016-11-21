// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SyncInfo.swift instead.

import Foundation
import CoreData

public enum SyncInfoAttributes: String {
    case lastRefreshTime = "lastRefreshTime"
}

public enum SyncInfoRelationships: String {
    case product = "product"
}

open class _SyncInfo: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "SyncInfo"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _SyncInfo.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var lastRefreshTime: Date?

    // MARK: - Relationships

    @NSManaged open
    var product: Product?

}

