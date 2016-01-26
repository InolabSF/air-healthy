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
        if AIRSensor.hasSensors() { return }

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

