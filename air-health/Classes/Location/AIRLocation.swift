import CoreData
import CoreLocation


/// MARK: - AIRLocation
class AIRLocation: NSManagedObject {

    /// MARK: - property
    @NSManaged var altitude: NSNumber
    @NSManaged var course: NSNumber
    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber
    @NSManaged var speed: NSNumber
    @NSManaged var hAccuracy: NSNumber
    @NSManaged var vAccuracy: NSNumber
    @NSManaged var timestamp: NSDate


    /// MARK: - class method

    /**
     * fetch stop locations
     * @param date NSDate
     * @return [CLLocation]
     **/
    class func fetchStops(date date: NSDate) -> [CLLocation] {
        let locations = AIRLocation.fetch(date: date)
        if locations.count == 0 { return [] }
        else if locations.count <= 2 { return [locations[0]] }

        let thresholdOfTimeInterval: NSTimeInterval = 300
        var stops: [CLLocation] = []

        // passing point
        for var i = 1; i < locations.count-1; i++ {
            if locations[i].timestamp.timeIntervalSinceDate(locations[i-1].timestamp) > thresholdOfTimeInterval {
                stops.append(locations[i-1])
            }
        }
        // final point
        stops.append(locations[locations.count-1])

        return stops
    }

    /**
     * fetch start locations
     * @param date NSDate
     * @return [CLLocation]
     **/
    class func fetchStarts(date date: NSDate) -> [CLLocation] {
        let locations = AIRLocation.fetch(date: date)
        if locations.count <= 2 { return [] }

        let thresholdOfTimeInterval: NSTimeInterval = 300
        var starts: [CLLocation] = []

        // passing point
        for var i = 1; i < locations.count-1; i++ {
            if locations[i].timestamp.timeIntervalSinceDate(locations[i-1].timestamp) > thresholdOfTimeInterval {
                starts.append(locations[i])
            }
        }

        return starts
    }

    /**
     * fetch datas
     * @param date NSDate
     * @return [CLLocation]
     */
    class func fetch(date date: NSDate) -> [CLLocation] {
        var locations: [CLLocation] = []

        let airLocations = AIRLocation.fetchAirLocations(date: date)
        for var i = 0; i < airLocations.count; i++ {
            let airLocation = airLocations[i]
            let location = CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: airLocation.lat.doubleValue, longitude: airLocation.lng.doubleValue),
                altitude: airLocation.altitude.doubleValue,
                horizontalAccuracy: airLocation.hAccuracy.doubleValue,
                verticalAccuracy: airLocation.vAccuracy.doubleValue,
                course: airLocation.course.doubleValue,
                speed: airLocation.speed.doubleValue,
                timestamp: airLocation.timestamp
            )
            locations.append(location)
        }

        return locations
    }

    /**
     * fetch datas
     * @param date NSDate
     * @return [AIRLocation]
     */
    class func fetchAirLocations(date date: NSDate) -> [AIRLocation] {
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("AIRLocation", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true),]
            // make predicates
        var startDate = date
        var endDate = startDate.air_daysAgo(days: -1)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.stringFromDate(startDate)
        let endDateString = dateFormatter.stringFromDate(endDate!)
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        startDate = dateFormatter.dateFromString(startDateString+" 00:00:00")!
        endDate = dateFormatter.dateFromString(endDateString+" 00:00:00")!
        let predicaets = [ NSPredicate(format: "(timestamp >= %@) AND (timestamp < %@)", startDate, endDate!), ]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)

        // return locations
        var locations: [AIRLocation]? = []
        do { locations = try context.executeFetchRequest(fetchRequest) as? [AIRLocation] }
        catch { return [] }
        return locations!
    }

    /**
     * save
     * @param location CLLocation
     **/
    class func save(location location: CLLocation) {
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        let airLocation = NSEntityDescription.insertNewObjectForEntityForName("AIRLocation", inManagedObjectContext: context) as! AIRLocation
        airLocation.lat = NSNumber(double: location.coordinate.latitude)
        airLocation.lng = NSNumber(double: location.coordinate.longitude)
        airLocation.altitude = NSNumber(double: location.altitude)
        airLocation.course = NSNumber(double: location.course)
        airLocation.speed = NSNumber(double: location.speed)
        airLocation.hAccuracy = NSNumber(double: location.horizontalAccuracy)
        airLocation.vAccuracy = NSNumber(double: location.verticalAccuracy)
        airLocation.timestamp = location.timestamp

        do { try context.save() }
        catch { return }
    }

    /**
     * save
     * @param locations [CLLocation]
     **/
    class func save(locations locations: [CLLocation]) {
        if locations.count == 0 { return }

        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        for var i = 0; i < locations.count; i++ {
            let location = locations[i]

            let airLocation = NSEntityDescription.insertNewObjectForEntityForName("AIRLocation", inManagedObjectContext: context) as! AIRLocation
            airLocation.lat = NSNumber(double: location.coordinate.latitude)
            airLocation.lng = NSNumber(double: location.coordinate.longitude)
            airLocation.altitude = NSNumber(double: location.altitude)
            airLocation.course = NSNumber(double: location.course)
            airLocation.speed = NSNumber(double: location.speed)
            airLocation.hAccuracy = NSNumber(double: location.horizontalAccuracy)
            airLocation.vAccuracy = NSNumber(double: location.verticalAccuracy)
            airLocation.timestamp = location.timestamp
        }

        do { try context.save() }
        catch { return }
    }

}
