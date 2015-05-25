
import CoreData
import CoreDataKit


@objc(ConfigurationSettings)
public class ConfigurationSettings: _ConfigurationSettings, NamedManagedObject {

    override public func awakeFromInsert() {
        super.awakeFromInsert()
    }
    
    public class var entityName : String {
        return self.mogen_entityName()
    }

}
