import CoreLocation


/// MARK: - AIRSensorClient
class AIRSensorClient: AnyObject {

    /// MARK: - property


    /// MARK: - class method

    static let sharedInstance = AIRSensorClient()


    /// MARK: - public api

    /**
     * request sensor datas
     * @param locations [CLLocation]
     * @param completionHandler (json: JSON) -> Void
     */
    func getSensorValues(locations locations: [CLLocation], completionHandler: (objects: [PFObject]?, error: NSError?) -> Void) {
        if locations.count == 0 { return }
        if AIRSensor.hasSensors() { return }

        // today
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(NSDate())
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let today = dateFormatter.dateFromString(dateString + " 00:00:00")!

        // get data from parse
        let southWest = AIRLocation.southWest(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfNeighbor)
        let northEast = AIRLocation.northEast(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfNeighbor)
        let query = PFQuery(className: "testData")
        query.limit = 300
        query.orderByAscending("createdAt")
        query.whereKey("createdAt", greaterThan: today.air_daysAgo(days: 1)!)
        query.whereKey("latitude", greaterThan: NSNumber(double: southWest.coordinate.latitude))
        query.whereKey("latitude", lessThan: NSNumber(double: northEast.coordinate.latitude))
        query.whereKey("longitude", greaterThan: NSNumber(double: southWest.coordinate.longitude))
        query.whereKey("longitude", lessThan: NSNumber(double: northEast.coordinate.longitude))
        query.findObjectsInBackgroundWithBlock(
            { (objects: [PFObject]?, error: NSError?) -> Void in
                completionHandler(objects: objects, error: error)
            }
        )
    }

}

