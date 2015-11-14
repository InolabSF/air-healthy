import CoreData


/// MARK: - AIRCoreDataManager
class AIRCoreDataManager {

    /// MARK: - property
    static let sharedInstance = AIRCoreDataManager()

    var managedObjectModel: NSManagedObjectModel {
        let modelURL = NSBundle.mainBundle().URLForResource("AIRModel", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }

    var managedObjectContext: NSManagedObjectContext {
        let coordinator = self.persistentStoreCoordinator

        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }

    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = documentsDirectories[documentsDirectories.count - 1] as NSURL
        let storeURL = documentsDirectory.URLByAppendingPathComponent("AIRModel.sqlite")

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
            try persistentStoreCoordinator.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: nil,
                URL: storeURL,
                options: options
            )
        } catch {
        }

        return persistentStoreCoordinator
    }


    /// MARK: - initialization
    init() {
    }

}
