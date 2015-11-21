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

        // stop points
        var stops: [CLLocation] = []
        var stopIndex = -1
        var endIndex = 1
        for var i = 0; i < locations.count-2; i = endIndex {
            stopIndex = -1
            endIndex = i + 1
            for var j = i+1; j < locations.count-1; j++ {
                let interval = locations[j].timestamp.timeIntervalSinceDate(locations[i].timestamp)
                let distance = locations[j].distanceFromLocation(locations[i])
                //AIRLOG("\(distance), \(AIRLocationManager.thresholdOfDistanceToStop), \(interval), \(AIRLocationManager.thresholdOfTimeIntervalToStop)")
                if distance > AIRLocationManager.thresholdOfDistanceToStop { endIndex = j; break }
                if interval > AIRLocationManager.thresholdOfTimeIntervalToStop { stopIndex = j }
            }
            if stopIndex < 0 { break }
            stops.append(locations[stopIndex-1])
        }

        if (stops.count == 0 && locations.last!.distanceFromLocation(locations.first!) > AIRLocationManager.thresholdOfDistanceToStop) ||
           (stops.count == 1 && locations.last!.distanceFromLocation(stops.last!) > AIRLocationManager.thresholdOfDistanceToStop) {
            stops = [locations.first!, locations.last!]
        }
        else if stops.count == 0 {
            stops = [locations.last!]
        }
        else {
            stops[0] = locations.first!
        }

        return stops
/*
        let locations = AIRLocation.fetch(date: date)
        if locations.count == 0 { return [] }
        else if locations.count <= 2 { return [locations[0]] }

        var firstStop = -1
        var stops: [CLLocation] = []
        // stop points
        for var i = 1; i < locations.count-1; i++ {
            if locations[i].timestamp.timeIntervalSinceDate(locations[i-1].timestamp) > AIRLocationManager.thresholdOfTimeIntervalToStop &&
               locations[i].distanceFromLocation(locations[i-1]) < AIRLocationManager.thresholdOfDistanceToStop {
                stops.append(locations[i-1])
                if firstStop < 0 { firstStop = i-1 }
            }
        }

        // first stop
        if firstStop >= 0 &&
           locations[0].distanceFromLocation(locations[firstStop]) > AIRLocationManager.thresholdOfDistanceToStop {
            stops = [locations[0]] + stops
        }
        // final stop
        if stops.count > 1 {
            stops.append(locations[locations.count-1])
        }

        return stops
*/
/*
        let locations = AIRLocation.fetch(date: date)
        if locations.count == 0 { return [] }
        else if locations.count <= 2 { return [locations[0]] }

        var stops: [CLLocation] = []
        // stop points
        for var i = 1; i < locations.count-1; i++ {
            if locations[i].timestamp.timeIntervalSinceDate(locations[i-1].timestamp) > AIRLocationManager.thresholdOfTimeIntervalToStop &&
               locations[i].distanceFromLocation(locations[i-1]) < AIRLocationManager.thresholdOfDistanceToStop {
                stops.append(locations[i-1])
            }
        }
        // final point
        stops.append(locations[locations.count-1])

        return stops
*/
    }

    /**
     * fetch start locations
     * @param date NSDate
     * @return [CLLocation]
     **/
    class func fetchStarts(date date: NSDate) -> [CLLocation] {
        let locations = AIRLocation.fetch(date: date)
        if locations.count <= 2 { return [] }

        // start points
        var starts: [CLLocation] = []
        var stopIndex = -1
        var endIndex = 1
        for var i = 0; i < locations.count-2; i = endIndex {
            stopIndex = -1
            endIndex = i + 1
            for var j = i+1; j < locations.count-1; j++ {
                let interval = locations[j].timestamp.timeIntervalSinceDate(locations[i].timestamp)
                let distance = locations[j].distanceFromLocation(locations[i])
                if distance > AIRLocationManager.thresholdOfDistanceToStop { endIndex = j; break }
                if interval > AIRLocationManager.thresholdOfTimeIntervalToStop { stopIndex = j }
            }
            if stopIndex < 0 { break }
            starts.append(locations[stopIndex])
        }
        if (starts.count == 0 && locations.last!.distanceFromLocation(locations.first!) > AIRLocationManager.thresholdOfDistanceToStop) ||
           (starts.count == 1 && stopIndex >= 0 && locations.last!.distanceFromLocation(locations[stopIndex-1]) > AIRLocationManager.thresholdOfDistanceToStop) {
            starts = [locations[1]]
        }
        else if starts.count == 1 && locations.last!.distanceFromLocation(starts.last!) <= AIRLocationManager.thresholdOfDistanceToStop {
            starts = []
        }

        return starts
/*
        let locations = AIRLocation.fetch(date: date)
        if locations.count <= 2 { return [] }

        var firstStop = -1
        var starts: [CLLocation] = []
        // start points
        for var i = 1; i < locations.count-1; i++ {
            if locations[i].timestamp.timeIntervalSinceDate(locations[i-1].timestamp) > AIRLocationManager.thresholdOfTimeIntervalToStop &&
               locations[i].distanceFromLocation(locations[i-1]) < AIRLocationManager.thresholdOfDistanceToStop {
                starts.append(locations[i])
                if firstStop < 0 { firstStop = i-1 }
            }
        }

        // first start
        if firstStop >= 0 &&
           locations[0].distanceFromLocation(locations[firstStop]) > AIRLocationManager.thresholdOfDistanceToStop {
            starts = [locations[1]] + starts
        }
        // not move
        if starts.count == 1 { starts = [] }

        return starts
*/
/*
        let locations = AIRLocation.fetch(date: date)
        if locations.count <= 2 { return [] }

        var starts: [CLLocation] = []
        // start points
        for var i = 1; i < locations.count-1; i++ {
            if locations[i].timestamp.timeIntervalSinceDate(locations[i-1].timestamp) > AIRLocationManager.thresholdOfTimeIntervalToStop &&
               locations[i].distanceFromLocation(locations[i-1]) < AIRLocationManager.thresholdOfDistanceToStop {
                starts.append(locations[i])
            }
        }
        return starts
*/
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
     * fetch south or west or north or east degree
     * @param latlng "lat" or "lng"
     * @param ascending Bool
     * @param date NSDate
     * @return CLLocation or nil
     */
    class func fetchSide(latlng latlng: String, ascending: Bool, date: NSDate) -> CLLocation? {
        if latlng != "lat" && latlng != "lng"  { return nil }

        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("AIRLocation", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: latlng, ascending: ascending),]
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
        catch { return nil }
        if locations!.count == 0 { return nil }

        return CLLocation(latitude: locations![0].lat.doubleValue, longitude: locations![0].lng.doubleValue)
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

    /**
     * get degree from meter
     * @param meter Double
     * @param latlng "lat" or "lng"
     * @param location CLLocation
     * @return Double
     **/
    class func degree(meter meter: Double, latlng: String, location: CLLocation) -> Double {
        if latlng != "lat" && latlng != "lng" { return 0 }
        let lat = (latlng == "lat") ? location.coordinate.latitude+1.0 : location.coordinate.latitude
        let lng = (latlng == "lng") ? location.coordinate.longitude+1.0 : location.coordinate.longitude

        let a = location
        let b = CLLocation(latitude: lat, longitude: lng)

        let distancePerOneDegree = b.distanceFromLocation(a)
        if distancePerOneDegree <= 0 { return 0 }
        return meter / distancePerOneDegree
    }

}
