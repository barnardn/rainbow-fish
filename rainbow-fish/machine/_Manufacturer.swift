// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Manufacturer.swift instead.

import Foundation
import CoreData

public enum ManufacturerAttributes: String {
    case isNew = "isNew"
    case modificationDate = "modificationDate"
    case name = "name"
    case ownerRecordIdentifier = "ownerRecordIdentifier"
    case recordID = "recordID"
}

public enum ManufacturerRelationships: String {
    case products = "products"
}

open class _Manufacturer: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Manufacturer"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Manufacturer.entity(managedObjectContext: managedObjectContext) else { return nil }
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
    var products: NSSet

    open func productsSet() -> NSMutableSet {
        return self.products.mutableCopy() as! NSMutableSet
    }

}

extension _Manufacturer {

    open func addProducts(_ objects: NSSet) {
        let mutable = self.products.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.products = mutable.copy() as! NSSet
    }

    open func removeProducts(_ objects: NSSet) {
        let mutable = self.products.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.products = mutable.copy() as! NSSet
    }

    open func addProductsObject(_ value: Product) {
        let mutable = self.products.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.products = mutable.copy() as! NSSet
    }

    open func removeProductsObject(_ value: Product) {
        let mutable = self.products.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.products = mutable.copy() as! NSSet
    }

}

