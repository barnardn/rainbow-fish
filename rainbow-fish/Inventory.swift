
import CoreData
import CoreDataKit
import Foundation

@objc(Inventory)
open  class Inventory: _Inventory, NamedManagedObject {
    /// The name of the entity as it is known in the managed object model
    
    open class var entityName : String {
        return self.entityName()
    }
    
}

extension Inventory {
    
    func populateWithPencil(_ pencil: Pencil) {
        self.name = pencil.name
        self.pencilIdentifier = pencil.identifier
        self.quantity = NSDecimalNumber(value: 0 as Int)
        self.productName = pencil.product?.name
        self.manufacturerName = pencil.product?.manufacturer?.name
        self.color = pencil.color
        self.pencil = pencil
    }
    
    class func fullInventory(inContext context: NSManagedObjectContext, sortedBy sortDescriptors: [NSSortDescriptor]?) -> [Inventory]? {
        var descriptors: [NSSortDescriptor]
        if sortDescriptors == nil {
            descriptors = [NSSortDescriptor(key: InventoryAttributes.name.rawValue, ascending: true)]
        } else {
            descriptors = sortDescriptors!
        }
        do {
            let results = try context.find(Inventory.self, predicate: nil, sortDescriptors: descriptors, limit: nil, offset: nil)
            return results
        } catch CoreDataKitError.coreDataError(let error) {
            print("Error \(error)")
            return nil
        } catch {
            return nil
        }
    }
    
    
}
