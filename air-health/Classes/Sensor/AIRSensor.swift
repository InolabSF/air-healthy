import CoreData
import CoreLocation


/// MARK: - AIRSensor
class AIRSensor: NSManagedObject {

    /// MARK: - property
    @NSManaged var value: NSNumber
    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber
    @NSManaged var name: String
    @NSManaged var timestamp: NSDate


    /// MARK: - class method

    /**
     * fetch today's sensor data
     * @param name String
     **/
/*
    class func fetch(name name: String) -> [AIRSensor] {
        let today = NSDate()

        var south = AIRLocation.fetchSide(latlng: "lat", ascending: true, date: today)
        var west = AIRLocation.fetchSide(latlng: "lng", ascending: true, date: today)
        var north = AIRLocation.fetchSide(latlng: "lat", ascending: false, date: today)
        var east = AIRLocation.fetchSide(latlng: "lng", ascending: false, date: today)
        if south == nil || west == nil || north == nil || east == nil { return [] }

        south = CLLocation(
            latitude: south!.coordinate.latitude - AIRLocation.degree(meter: 50, latlng: "lat", location: south!),
            longitude: south!.coordinate.longitude
        )
        west = CLLocation(
            latitude: west!.coordinate.latitude,
            longitude: west!.coordinate.longitude - AIRLocation.degree(meter: 50, latlng: "lng", location: west!)
        )
        north = CLLocation(
            latitude: north!.coordinate.latitude + AIRLocation.degree(meter: 50, latlng: "lat", location: north!),
            longitude: north!.coordinate.longitude
        )
        east = CLLocation(
            latitude: east!.coordinate.latitude,
            longitude: east!.coordinate.longitude + AIRLocation.degree(meter: 50, latlng: "lng", location: east!)
        )

        return AIRSensor.fetch(
            name: name,
            date: today,
            southWest: CLLocation(latitude: south!.coordinate.latitude, longitude: west!.coordinate.longitude),
            northEast: CLLocation(latitude: north!.coordinate.latitude, longitude: east!.coordinate.longitude)
        )
    }
*/

    /**
     * fetch
     * @param name String
     * @param date NSDate
     * @param southWest CLLocation
     * @param northEast CLLocation
     * @return [AIRSensor]
     */
    class func fetch(name name: String, date: NSDate, southWest: CLLocation, northEast: CLLocation) -> [AIRSensor] {
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("AIRSensor", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "lat", ascending: true),
            NSSortDescriptor(key: "lng", ascending: true),
        ]
            // make predicates
        let startDate = date.air_daysAgo(days: 14)
        let endDate = date.air_daysAgo(days: -14)
        let predicaets = [
            NSPredicate(format: "(timestamp >= %@) AND (timestamp < %@)", startDate!, endDate!),
            NSPredicate(format: "(lat > %f) AND (lng < %f)", southWest.coordinate.latitude, northEast.coordinate.latitude),
            NSPredicate(format: "(lng > %f) AND (lng < %f)", southWest.coordinate.longitude, northEast.coordinate.longitude),
        ]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)

        // return locations
        var sensors: [AIRSensor]? = []
        do { sensors = try context.executeFetchRequest(fetchRequest) as? [AIRSensor] }
        catch { return [] }
        return sensors!
    }

    /**
     * save
     * @param json JSON
     **/
    class func save(json json: JSON) {
        let sensors = json.arrayValue
        if sensors.count == 0 { return }

        let names = ["CO", "SO2", "Ozone_S",]
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        for s in sensors {
            for name in names {
                let sensor = NSEntityDescription.insertNewObjectForEntityForName("AIRSensor", inManagedObjectContext: context) as! AIRSensor
                sensor.value = s[name].numberValue
                sensor.lat = s["latitude"].numberValue
                sensor.lng = s["longitude"].numberValue
                sensor.name = name
                sensor.timestamp = NSDate(timeIntervalSince1970: s["time"].doubleValue)
            }
        }

        do { try context.save() }
        catch { return }
    }

}
