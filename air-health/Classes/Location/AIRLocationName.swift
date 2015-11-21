import CoreData
import CoreLocation


/// MARK: - AIRLocationName
class AIRLocationName: NSManagedObject {

    /// MARK: - property
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber


    /// MARK: - class method

    /**
     * fetch datas
     * @param location CLLocation
     * @return AIRLocationName?
     */
    class func fetch(location location: CLLocation) -> AIRLocationName? {
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("AIRLocationName", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 1
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
            // make predicates
        let latOffset = AIRLocation.degree(meter: 50, latlng: "lat", location: location)
        let lngOffset = AIRLocation.degree(meter: 50, latlng: "lng", location: location)
        let predicaets = [
            NSPredicate(format: "(lat > %f) AND (lat < %f)", location.coordinate.latitude-latOffset, location.coordinate.latitude+latOffset),
            NSPredicate(format: "(lng > %f) AND (lng < %f)", location.coordinate.longitude-lngOffset, location.coordinate.longitude+lngOffset),
        ]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)

        // return
        var names: [AIRLocationName]? = []
        do {
            names = try context.executeFetchRequest(fetchRequest) as? [AIRLocationName]
        }
        catch { names = [] }
        return (names!.count > 0) ? names![0] : nil
    }

    /**
     * save
     * @param json JSON
     **/
    class func save(json json: JSON) {
        let names = json["results"].arrayValue
        for name in names {
            let lat = name["geometry"]["location"]["lat"].doubleValue
            let lng = name["geometry"]["location"]["lng"].doubleValue
            let type = (name["type"].arrayValue.count > 0) ? name["type"].arrayValue[0].stringValue : "none"
            AIRLocationName.save(name: name["name"].stringValue, type: type, lat: lat, lng: lng)
        }
    }

    /**
     * save
     * @param name String
     * @param type String
     * @param lat Double
     * @param lng Double
     **/
    class func save(name name: String, type: String, lat: Double, lng: Double) {
        let context = AIRCoreDataManager.sharedInstance.managedObjectContext

        let n = NSEntityDescription.insertNewObjectForEntityForName("AIRLocationName", inManagedObjectContext: context) as! AIRLocationName
        n.lat = NSNumber(double: lat)
        n.lng = NSNumber(double: lng)
        n.name = name
        n.type = type

        do { try context.save() }
        catch { return }
    }

}
