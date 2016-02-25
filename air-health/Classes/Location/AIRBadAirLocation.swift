//import CoreData
//import CoreLocation
//
//
///// MARK: - AIRBadAirLocation
//class AIRBadAirLocation: NSManagedObject {
//
//    /// MARK: - property
//    @NSManaged var altitude: NSNumber
//    @NSManaged var course: NSNumber
//    @NSManaged var lat: NSNumber
//    @NSManaged var lng: NSNumber
//    @NSManaged var speed: NSNumber
//    @NSManaged var hAccuracy: NSNumber
//    @NSManaged var vAccuracy: NSNumber
//    @NSManaged var timestamp: NSDate
//
//
//    /**
//     * fetch datas
//     * @return [CLLocation]
//     */
//    class func fetch() -> [CLLocation] {
//        var locations: [CLLocation] = []
//
//        let airLocations = AIRBadAirLocation.fetchAirLocations()
//        for var i = 0; i < airLocations.count; i++ {
//            let airLocation = airLocations[i]
//            let location = CLLocation(
//                coordinate: CLLocationCoordinate2D(latitude: airLocation.lat.doubleValue, longitude: airLocation.lng.doubleValue),
//                altitude: airLocation.altitude.doubleValue,
//                horizontalAccuracy: airLocation.hAccuracy.doubleValue,
//                verticalAccuracy: airLocation.vAccuracy.doubleValue,
//                course: airLocation.course.doubleValue,
//                speed: airLocation.speed.doubleValue,
//                timestamp: airLocation.timestamp
//            )
//            locations.append(location)
//        }
//
//        return locations
//    }
//
//    /**
//     * fetch datas
//     * @return [AIRBadAirLocation]
//     */
//    class func fetchAirLocations() -> [AIRBadAirLocation] {
//        let context = AIRCoreDataManager.sharedInstance.managedObjectContext
//
//        // make fetch request
//        let fetchRequest = NSFetchRequest()
//        let entity = NSEntityDescription.entityForName("AIRBadAirLocation", inManagedObjectContext:context)
//        fetchRequest.entity = entity
//        fetchRequest.fetchBatchSize = 20
//        fetchRequest.returnsObjectsAsFaults = false
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true),]
//
//        // return locations
//        var locations: [AIRBadAirLocation]? = []
//        do { locations = try context.executeFetchRequest(fetchRequest) as? [AIRBadAirLocation] }
//        catch { return [] }
//        return locations!
//    }
//
//    /**
//     * save
//     * @param location CLLocation
//     **/
//    class func save(location location: CLLocation) {
//        let context = AIRCoreDataManager.sharedInstance.managedObjectContext
//
//        let airLocation = NSEntityDescription.insertNewObjectForEntityForName("AIRBadAirLocation", inManagedObjectContext: context) as! AIRBadAirLocation
//        airLocation.lat = NSNumber(double: location.coordinate.latitude)
//        airLocation.lng = NSNumber(double: location.coordinate.longitude)
//        airLocation.altitude = NSNumber(double: location.altitude)
//        airLocation.course = NSNumber(double: location.course)
//        airLocation.speed = NSNumber(double: location.speed)
//        airLocation.hAccuracy = NSNumber(double: location.horizontalAccuracy)
//        airLocation.vAccuracy = NSNumber(double: location.verticalAccuracy)
//        airLocation.timestamp = location.timestamp
//
//        do { try context.save() }
//        catch { return }
//    }
//
//    /**
//     * delete all entity datas
//     **/
//    class func deleteAll() {
//        let context = AIRCoreDataManager.sharedInstance.managedObjectContext
//
//        let fetchRequest = NSFetchRequest()
//        fetchRequest.entity = NSEntityDescription.entityForName("AIRBadAirLocation", inManagedObjectContext: context)
//        fetchRequest.includesPropertyValues = false
//        do {
//            if let results = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
//                for result in results {
//                    context.deleteObject(result)
//                }
//
//                try context.save()
//            }
//        }
//        catch {
//            return
//        }
//    }
//
//
//}
