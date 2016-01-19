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
    //func getSensorValues(locations locations: [CLLocation], completionHandler: (objects: [PFObject]?, error: NSError?) -> Void)
    func getSensorValues(locations locations: [CLLocation], completionHandler: (json: JSON) -> Void) {
        //if locations.count == 0 { return }
        if AIRSensor.hasSensors() { return }
/*
        // today
        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(NSDate())
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let today = dateFormatter.dateFromString(dateString + " 00:00:00")!

        // get data from parse
        let southWest = AIRLocation.southWest(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
        let northEast = AIRLocation.northEast(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
        let query = PFQuery(className: "testData")
        query.limit = 1000
        query.orderByAscending("createdAt")

        query.whereKey("createdAt", greaterThan: today.air_daysAgo(days: AIRSensorManager.DaysAgo)!)
        query.whereKey("latitude", greaterThan: NSNumber(double: southWest.coordinate.latitude))
        query.whereKey("latitude", lessThan: NSNumber(double: northEast.coordinate.latitude))
        query.whereKey("longitude", greaterThan: NSNumber(double: southWest.coordinate.longitude))
        query.whereKey("longitude", lessThan: NSNumber(double: northEast.coordinate.longitude))
        query.findObjectsInBackgroundWithBlock(
            { (objects: [PFObject]?, error: NSError?) -> Void in
                completionHandler(objects: objects, error: error)
            }
        )
*/


        let request = NSMutableURLRequest(URL: NSURL(string: "https://vasp.herokuapp.com/air")!)

        // request
        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON["airs"])
                })
            }
        )
        AIRSensorOperationQueue.defaultQueue().addOperation(operation)

    }

}

