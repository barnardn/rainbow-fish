// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConfigurationSettings.swift instead.

/*

	_ConfigurationSettings.swift

	Generated by mogenerator
	Copyright (c) 2015 Norm Barnard

*/

import CoreData

public enum ConfigurationSettingsAttributes: String {
    case iCloudRecordID = "iCloudRecordID"
    case minInventoryQuantity = "minInventoryQuantity"
    case ownerRecordIdentifier = "ownerRecordIdentifier"
    case recordID = "recordID"
}

@objc public
class _ConfigurationSettings: NSManagedObject {

    // MARK: - Class methods

	public class func mogen_entityName () -> String {
        return "ConfigurationSettings"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.mogen_entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _ConfigurationSettings.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var iCloudRecordID: String?

    // func validateICloudRecordID(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var minInventoryQuantity: NSDecimalNumber?

    // func validateMinInventoryQuantity(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var ownerRecordIdentifier: String?

    // func validateOwnerRecordIdentifier(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var recordID: NSNumber?

    // func validateRecordID(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

}

