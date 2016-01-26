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

//    /**
//     * fetch stop locations
//     * @param date NSDate
//     * @return [CLLocation]
//     **/
//    class func fetchStops(date date: NSDate) -> [CLLocation] {
//        let locations = AIRLocation.fetch(date: date)
//        if locations.count == 0 { return [] }
//        else if locations.count <= 2 { return [locations.first!] }
//
//        // stop points
//        var stops: [CLLocation] = [locations.first!]
//        var canBeStop = locations.first!
//        for var i = 1; i < locations.count; i++ {
//            if locations[i].distanceFromLocation(canBeStop) <= AIRLocationManager.ThresholdOfDistanceToStop { continue }
//            canBeStop = locations[i]
//
//            for var j = i+1; j < locations.count; j++ {
//                let interval = locations[j].timeIntervalSinceDate(canBeStop.timestamp)
//                if interval <= AIRLocationManager.ThresholdOfTimeIntervalToStop { continue }
//            }
//        }
//
//        AIRLOG("stops")
//        for var i = 0; i < stops.count; i++ {
//            AIRLOG(stops[i].timestamp)
//        }
//
//        return stops
//
///*
//        // stop points
//        var stops: [CLLocation] = []
//        var stopEndIndex = -1
//        var nextIndex = 1
//        for var i = 0; i < locations.count-2; i = nextIndex {
//            stopEndIndex = -1
//            nextIndex = -1
//            for var j = i+1; j < locations.count-1; j++ {
//                let interval = locations[j].timestamp.timeIntervalSinceDate(locations[i].timestamp)
//                let distance = locations[j].distanceFromLocation(locations[i])
//                if interval > AIRLocationManager.ThresholdOfTimeIntervalToStop { stopEndIndex = j }
//                if distance > AIRLocationManager.ThresholdOfDistanceToStop { nextIndex = j; break }
//            }
//            if nextIndex < 0 {
//                if stopEndIndex >= 0 { stops.append(locations[i]) }
//                break
//            }
//            if stopEndIndex < 0 { continue }
//            stops.append(locations[i])
//        }
//        if stops.count == 0 { stops = [locations.first!] }
//        else if locations.last!.distanceFromLocation(stops.last!) > AIRLocationManager.ThresholdOfDistanceToStop {
//            stops.append(locations.last!)
//        }
//
//        AIRLOG("stops")
//        for var i = 0; i < stops.count; i++ {
//            AIRLOG(stops[i].timestamp)
//        }
//
//        return stops
//*/
//    }
//
//    /**
//     * fetch starts locations
//     * @param date NSDate
//     * @return [CLLocation]
//     **/
//    class func fetchStarts(date date: NSDate) -> [CLLocation] {
//        let locations = AIRLocation.fetch(date: date)
//        if locations.count <= 2 { return [] }
///*
//        // start points
//        var starts: [CLLocation] = []
//        var stopEndIndex = -1
//        //var lastStopIndex = -1
//        var nextIndex = 1
//        for var i = 0; i < locations.count-2; i = nextIndex {
//            stopEndIndex = -1
//            nextIndex = -1
//            for var j = i+1; j < locations.count-1; j++ {
//                let interval = locations[j].timestamp.timeIntervalSinceDate(locations[i].timestamp)
//                let distance = locations[j].distanceFromLocation(locations[i])
//                if interval > AIRLocationManager.ThresholdOfTimeIntervalToStop { stopEndIndex = j }
//                if distance > AIRLocationManager.ThresholdOfDistanceToStop { nextIndex = j; break }
//            }
//            if nextIndex < 0 {
//                break
//            }
//            if stopEndIndex < 0 { continue }
//            starts.append(locations[stopEndIndex])
//            //lastStopIndex = i
//        }
//
//        AIRLOG("starts")
//        for var i = 0; i < starts.count; i++ {
//            AIRLOG(starts[i].timestamp)
//        }
//
//        return starts
//*/
//    }


//    /**
//     * fetch start locations
//     * @param date NSDate
//     * @return [CLLocation]
//     **/
//    class func fetchStarts(date date: NSDate) -> [CLLocation] {
//        let locations = AIRLocation.fetch(date: date)
//        if locations.count <= 2 { return [] }
//
//        // start points
//        var starts: [CLLocation] = []
//        var startIndex = -1
//        var endIndex = 1
//        for var i = 0; i < locations.count-2; i = endIndex {
//            startIndex = -1
//            endIndex = i + 1
//            for var j = i+1; j < locations.count-1; j++ {
//                let interval = locations[j].timestamp.timeIntervalSinceDate(locations[i].timestamp)
//                let distance = locations[j].distanceFromLocation(locations[i])
//                if distance > AIRLocationManager.ThresholdOfDistanceToStop { endIndex = j + 1; break }
//                if interval > AIRLocationManager.ThresholdOfTimeIntervalToStop { startIndex = j }
//            }
//            if startIndex < 0 { continue }
//            starts.append(locations[startIndex])
//        }
//
//        if starts.count == 0 {
//            if locations.last!.distanceFromLocation(locations.first!) > AIRLocationManager.ThresholdOfDistanceToStop {
//                starts = [locations[1]]
//            }
//        }
//        AIRLOG(starts.count)
//        return starts
//    }

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
     * fetch last location
     * @param date NSDate
     * @return CLLocation?
     */
    class func fetchLast(date date: NSDate) -> CLLocation? {
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("AIRLocation", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 1
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false),]
            // make predicates
        var startDate = date
        var endDate = startDate.air_daysAgo(days: -1)
        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.stringFromDate(startDate)
        let endDateString = dateFormatter.stringFromDate(endDate!)
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        startDate = dateFormatter.dateFromString(startDateString+" 00:00:00")!
        endDate = dateFormatter.dateFromString(endDateString+" 00:00:00")!
        let predicaets = [ NSPredicate(format: "(timestamp >= %@) AND (timestamp < %@)", startDate, endDate!), ]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)

        // locations
        var locations: [AIRLocation]? = []
        do { locations = try context.executeFetchRequest(fetchRequest) as? [AIRLocation] }
        catch { locations = [] }
        if locations!.count == 0 {
            return nil
        }

        // location
        let airLocation = locations![0]
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: airLocation.lat.doubleValue, longitude: airLocation.lng.doubleValue),
            altitude: airLocation.altitude.doubleValue,
            horizontalAccuracy: airLocation.hAccuracy.doubleValue,
            verticalAccuracy: airLocation.vAccuracy.doubleValue,
            course: airLocation.course.doubleValue,
            speed: airLocation.speed.doubleValue,
            timestamp: airLocation.timestamp
        )
        return location
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
        let startDate = date.air_daysAgo(days: 1)
        let endDate = date
        let predicaets = [ NSPredicate(format: "(timestamp >= %@) AND (timestamp <= %@)", startDate!, endDate), ]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)
/*
        var startDate = date
        var endDate = startDate.air_daysAgo(days: -1)
        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.stringFromDate(startDate)
        let endDateString = dateFormatter.stringFromDate(endDate!)
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        startDate = dateFormatter.dateFromString(startDateString+" 00:00:00")!
        endDate = dateFormatter.dateFromString(endDateString+" 00:00:00")!
        let predicaets = [ NSPredicate(format: "(timestamp >= %@) AND (timestamp < %@)", startDate, endDate!), ]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)
*/
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
        let dateFormatter = NSDateFormatter.air_dateFormatter()
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

    /**
     * get southWest location
     * @param locations CLLocation
     * @return CLLocation
     **/
    class func southWest(locations locations: [CLLocation]) -> CLLocation {
        // get locations rect
        var minLat = 90.0
        var minLng = 180.0
        for location in locations {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            if minLat > lat { minLat = lat }
            if minLng > lng { minLng = lng }
        }
        return CLLocation(latitude: minLat, longitude: minLng)
    }

    /**
     * get northEast location
     * @param locations CLLocation
     * @return CLLocation
     **/
    class func northEast(locations locations: [CLLocation]) -> CLLocation {
        var maxLat = -90.0
        var maxLng = -180.0
        for location in locations {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            if maxLat < lat { maxLat = lat }
            if maxLng < lng { maxLng = lng }
        }
        return CLLocation(latitude: maxLat, longitude: maxLng)
    }

    /**
     * get southWest location
     * @param locations CLLocation
     * @param offset meters Double
     * @return CLLocation
     **/
    class func southWest(locations locations: [CLLocation], offsetMeters: Double) -> CLLocation {
        let location = AIRLocation.southWest(locations: locations)
        let latOffset = AIRLocation.degree(meter: offsetMeters, latlng: "lat", location: location)
        let lngOffset = AIRLocation.degree(meter: offsetMeters, latlng: "lng", location: location)
        return CLLocation(latitude: location.coordinate.latitude-latOffset, longitude: location.coordinate.longitude-lngOffset)
    }

    /**
     * get northEast location
     * @param locations CLLocation
     * @param offset meters Double
     * @return CLLocation
     **/
    class func northEast(locations locations: [CLLocation], offsetMeters: Double) -> CLLocation {
        let location = AIRLocation.northEast(locations: locations)
        let latOffset = AIRLocation.degree(meter: offsetMeters, latlng: "lat", location: location)
        let lngOffset = AIRLocation.degree(meter: offsetMeters, latlng: "lng", location: location)
        return CLLocation(latitude: location.coordinate.latitude+latOffset, longitude: location.coordinate.longitude+lngOffset)
    }


}
