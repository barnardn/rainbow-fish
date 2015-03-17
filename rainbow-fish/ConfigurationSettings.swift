
import CoreData
import CoreDataKit


@objc(ConfigurationSettings)
class ConfigurationSettings: _ConfigurationSettings, NamedManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()
    }
    
    // MARK: NamedManagedObject
    
    class var entityName: String { return self.entityName() }


}
