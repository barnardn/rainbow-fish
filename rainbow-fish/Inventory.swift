
import CoreData
import CoreDataKit
import Foundation

@objc(Inventory)
public  class Inventory: _Inventory, NamedManagedObject {

    public class var entityName : String {
        return self.mogen_entityName()
    }
    
}

extension Inventory {
    
    func populateWithPencil(pencil: Pencil) {
        self.name = pencil.name
        self.pencilIdentifier = pencil.identifier
        self.quantity = NSDecimalNumber(integer: 0)
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
        switch context.find(Inventory.self, predicate: nil, sortDescriptors: descriptors, limit: nil, offset: nil) {
        case let .Failure(error):
            assertionFailure(error.localizedDescription)
        case let .Success(boxedResults):
            return boxedResults.value
        }
        return nil
    }
    
    
}
