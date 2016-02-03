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
     * fetch
     * @return [AIRSensor]
     */
    class func fetch() -> [AIRSensor] {
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

        // return locations
        var sensors: [AIRSensor]? = []
        do { sensors = try context.executeFetchRequest(fetchRequest) as? [AIRSensor] }
        catch { return [] }
        return sensors!
    }

    /**
     * fetch
     * @param date NSDate
     * @param southWest CLLocation
     * @param northEast CLLocation
     * @return [AIRSensor]
     */
    class func fetch(date date: NSDate, southWest: CLLocation, northEast: CLLocation) -> [AIRSensor] {
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("AIRSensor", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
/*
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "lat", ascending: true),
            NSSortDescriptor(key: "lng", ascending: true),
        ]
*/
            // make predicates
        let startDate = date.air_daysAgo(days: AIRSensorManager.DaysAgo+1)!
        let endDate = date
        let predicaets = [
            NSPredicate(format: "(timestamp >= %@) AND (timestamp < %@)", startDate, endDate),
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
/*
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "lat", ascending: true),
            NSSortDescriptor(key: "lng", ascending: true),
        ]
*/
            // make predicates
        let startDate = date.air_daysAgo(days: AIRSensorManager.DaysAgo+1)!
        let endDate = date
        let predicaets = [
            NSPredicate(format: "name = %@", name),
            NSPredicate(format: "(timestamp >= %@) AND (timestamp < %@)", startDate, endDate),
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

        let names = ["UV", "NO2","PM25", "CO", "SO2", "Ozone_S",]
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        for s in sensors {
            for name in names {
                let sensor = NSEntityDescription.insertNewObjectForEntityForName("AIRSensor", inManagedObjectContext: context) as! AIRSensor

                //sensor.value = s[name].numberValue
                //sensor.lat = s["latitude"].numberValue
                //sensor.lng = s["longitude"].numberValue
                //sensor.lat = NSNumber(double: (s["north"].numberValue.doubleValue + s["south"].numberValue.doubleValue) / 2.0)
                //sensor.lng = NSNumber(double: (s["west"].numberValue.doubleValue + s["east"].numberValue.doubleValue) / 2.0)

                sensor.value = s[name.lowercaseString].numberValue
                sensor.lat = s["lat"].numberValue
                sensor.lng = s["lng"].numberValue

                sensor.name = name
                sensor.timestamp = NSDate().air_daysAgo(days: 1)!//NSDate(timeIntervalSince1970: s["time"].doubleValue)
            }
        }

        do { try context.save() }
        catch { return }

        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let todayString = dateFormatter.stringFromDate(NSDate())
        NSUserDefaults().setObject(todayString, forKey: AIRUserDefaults.SensorDate)
        NSUserDefaults().synchronize()
    }

    /**
     * check if the phone already has sensor data
     * @return Bool
     **/
    class func hasSensors() -> Bool {
//        return false
/*
        // today
        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.stringFromDate(NSDate())
        let sensorDate = NSUserDefaults().stringForKey(AIRUserDefaults.SensorDate)
        return (todayString == sensorDate)
*/
        // today
        let today = NSDate()

        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let sensorDateString = NSUserDefaults().stringForKey(AIRUserDefaults.SensorDate)
        if sensorDateString == nil { return false }
        let sensorDate = dateFormatter.dateFromString(sensorDateString!)
        if sensorDate == nil { return false }

        //let hour = Int(today.timeIntervalSinceDate(sensorDate!)) / 60 / 60
        //return (hour <= 0)
        let tenMinutes = Int(today.timeIntervalSinceDate(sensorDate!)) / 60 / 10
        return (tenMinutes <= 0)
    }

    /**
     * delete all entity datas
     **/
    class func deleteAll() {
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("AIRSensor", inManagedObjectContext: context)
        fetchRequest.includesPropertyValues = false
        do {
            if let results = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    context.deleteObject(result)
                }

                try context.save()
            }
        }
        catch {
            return
        }
    }

//    /**
//     * convert ppm to mgqm
//     * @param ppm Double
//     * @param molecularMass Double
//     * @param temperature Double
//     * @return mgqm
//     **/
//    class func PPMToMGQM(ppm ppm: Double, molecularMass: Double, temperature: Double) -> Double {
//        let molarVolumeOfAir = (273.0 + temperature) / 273.0 * 22.4
//        if molarVolumeOfAir == 0 { return 0 }
//        return (ppm * molecularMass / molarVolumeOfAir)
//    }
//
//    /**
//     * convert raw Ozone_S data to data we can understand
//     * @param value Double
//     * @param temperature Double
//     * @return ozone
//     **/
//    class func convertOzone_S(value value: Double, temperature: Double) -> Double {
//        let code = 17.55
//        let tiaO3 = 499.0
//        let tcO3 = 0.01
//        let verfO3 = 1.2
//        let voffsetO3 = 0.2
//
//        let m = code * tiaO3 * 10e-6
//        let mc = m * (1 + tcO3 * (20.0 - temperature))
//        let vgas = value / 1024.0 * 3.3
//        let c = 1.0 / mc * (vgas - verfO3 - voffsetO3)
//        return AIRSensor.PPMToMGQM(ppm: c, molecularMass: 48.0, temperature: temperature) * 10.0
//    }
//
//    /**
//     * convert raw Ozone_S data to data we can understand
//     * @param value Double
//     * @param temperature Double
//     * @return ozone
//     **/
//    class func convertSO2(value value: Double, temperature: Double) -> Double {
//        let code = 30.0
//        let tiaSO2 = 100.0
//        let tcSO2 = 0.01
//        let verfSO2 = 1.2
//        let voffsetSO2 = 0.2
//
//        let m = code * tiaSO2 * 10e-6
//        let mc = m * (1.0 + tcSO2 * (20.0 - temperature))
//        let vgas = value / 1024.0 * 3.3
//        if mc == 0 { return 0 }
//        let c = 1.0 / mc * (vgas - verfSO2 - voffsetSO2)
//        return AIRSensor.PPMToMGQM(ppm: c, molecularMass: 64.066, temperature: temperature) * 10.0
//    }

}
