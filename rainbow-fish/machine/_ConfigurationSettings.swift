// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConfigurationSettings.swift instead.

import CoreData

enum ConfigurationSettingsAttributes: String {
    case minInventoryQuantity = "minInventoryQuantity"
}

@objc
class _ConfigurationSettings: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "ConfigurationSettings"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _ConfigurationSettings.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var minInventoryQuantity: NSDecimalNumber?

    // func validateMinInventoryQuantity(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

}

