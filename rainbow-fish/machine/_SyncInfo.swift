// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SyncInfo.swift instead.

import CoreData

enum SyncInfoAttributes: String {
    case lastRefreshTime = "lastRefreshTime"
}

enum SyncInfoRelationships: String {
    case product = "product"
}

@objc
class _SyncInfo: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "SyncInfo"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _SyncInfo.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var lastRefreshTime: NSDate?

    // func validateLastRefreshTime(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var product: Product?

    // func validateProduct(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

