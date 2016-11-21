// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Product.swift instead.

import Foundation
import CoreData

public enum ProductAttributes: String {
    case isNew = "isNew"
    case modificationDate = "modificationDate"
    case name = "name"
    case ownerRecordIdentifier = "ownerRecordIdentifier"
    case recordID = "recordID"
}

public enum ProductRelationships: String {
    case manufacturer = "manufacturer"
    case pencils = "pencils"
    case syncInfo = "syncInfo"
}

open class _Product: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Product"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Product.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

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
    var manufacturer: Manufacturer?

    @NSManaged open
    var pencils: NSSet

    open func pencilsSet() -> NSMutableSet {
        return self.pencils.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var syncInfo: SyncInfo?

}

extension _Product {

    open func addPencils(_ objects: NSSet) {
        let mutable = self.pencils.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.pencils = mutable.copy() as! NSSet
    }

    open func removePencils(_ objects: NSSet) {
        let mutable = self.pencils.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.pencils = mutable.copy() as! NSSet
    }

    open func addPencilsObject(_ value: Pencil) {
        let mutable = self.pencils.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.pencils = mutable.copy() as! NSSet
    }

    open func removePencilsObject(_ value: Pencil) {
        let mutable = self.pencils.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.pencils = mutable.copy() as! NSSet
    }

}

