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
     * @param date NSDate
     * @param completionHandler (json: JSON) -> Void
     */
    //func getSensorValues(locations locations: [CLLocation], completionHandler: (objects: [PFObject]?, error: NSError?) -> Void)
    //func getSensorValues(locations locations: [CLLocation], completionHandler: (json: JSON) -> Void) {
    func getSensorValues(locations locations: [CLLocation], date: NSDate, completionHandler: (json: JSON) -> Void) {
        //if AIRSensor.hasSensors() { return }

        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH"
        let time = dateFormatter.stringFromDate(date)

        let southWest = AIRLocation.southWest(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
        let northEast = AIRLocation.northEast(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)

        let URL = NSURL(
            //URLString: "https://vasp.herokuapp.com/air",
            URLString: "https://vasp.herokuapp.com/square",
            queries: [
                "south":"\(southWest.coordinate.latitude)",
                "north":"\(northEast.coordinate.latitude)",
                "west":"\(southWest.coordinate.longitude)",
                "east":"\(northEast.coordinate.longitude)",
                "time":"\(time)",
            ]
        )
        let request = NSMutableURLRequest(URL: URL!)

        // request
        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    //completionHandler(json: responseJSON["airs"])
                    completionHandler(json: responseJSON["squares"])
                })
            }
        )
        AIRSensorOperationQueue.defaultQueue().addOperation(operation)

    }

}

