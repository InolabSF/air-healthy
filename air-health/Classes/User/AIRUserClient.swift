import CoreLocation


/// MARK: - AIRUserClient
class AIRUserClient: AnyObject {

    /// MARK: - property


    /// MARK: - class method

    static let sharedInstance = AIRUserClient()


    /// MARK: - public api

    /**
     * post user
     * @param userIsOn Bool
     * @param location CLLocation
     * @param completionHandler (json: JSON) -> Void
     */
    func postUser(userIsOn userIsOn: Bool, location: CLLocation, completionHandler: (json: JSON) -> Void) {
        let today = NSDate()

        // UUID
        let UUID = NSUserDefaults().stringForKey(AIRUserDefaults.UUID)
        if UUID == nil { return }
        // user name
        var name = UIDevice.currentDevice().name
        name = name.stringByReplacingOccurrencesOfString("'s iPhone", withString: "")
        name = name.stringByReplacingOccurrencesOfString("iPhone", withString: "")
        if name == "" { return }
        // air pollution
        var air = 0
        let o3 = AIRSensorManager.averageSensorValue(name: "Ozone_S", date: today, location: location) / AIRSensorManager.WHOBasementOzone_S_2
        let so2 = AIRSensorManager.averageSensorValue(name: "SO2", date: today, location: location) / AIRSensorManager.WHOBasementSO2_2
        let value = (o3 + so2)
        if value < AIRSensorManager.Basement_1 { air = 0 }
        else if value < AIRSensorManager.Basement_2 { air = 1 }
        else { air = 2 }
        // lat, lng
        let lat = (userIsOn) ? location.coordinate.latitude : -999.0
        let lng = (userIsOn) ? location.coordinate.longitude : -999.0

        // request
        let request = NSMutableURLRequest(
            URL: NSURL(
                URLString: "https://vasp.herokuapp.com/user",
                queries: [
                    "uuid": UUID!,
                    "name": name,
                    "lat": "\(lat)",
                    "lng": "\(lng)",
                    "air": "\(air)",
                ]
            )!
        )
        request.HTTPMethod = "POST"
        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                    if userIsOn {
                        let dateFormatter = NSDateFormatter.air_dateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let todayString = dateFormatter.stringFromDate(NSDate())
                        NSUserDefaults().setObject(todayString, forKey: AIRUserDefaults.UserDate)
                        NSUserDefaults().synchronize()
                    }
                    else {
                        NSUserDefaults().setObject("", forKey: AIRUserDefaults.UserDate)
                        NSUserDefaults().synchronize()
                    }
                })
            }
        )
        AIRUserOperationQueue.defaultQueue().addOperation(operation)
    }

    /**
     * post user
     * @param location CLLocation
     * @param completionHandler (json: JSON) -> Void
     */
    func postUser(location location: CLLocation, completionHandler: (json: JSON) -> Void) {
        let userIsOn = NSUserDefaults().boolForKey(AIRUserDefaults.UserIsOn)
        if !userIsOn { return }

        // time interval from last time
        let today = NSDate()
        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let userDateString = NSUserDefaults().stringForKey(AIRUserDefaults.UserDate)
        if userDateString != nil {
            let userDate = dateFormatter.dateFromString(userDateString!)
            if userDate != nil {
                let hour = Int(today.timeIntervalSinceDate(userDate!)) / 60 / 60
                if hour <= 0 { return }
            }
        }

        self.postUser(userIsOn: userIsOn, location: location, completionHandler: completionHandler)
    }

    /**
     * get user
     * @param location CLLocation
     * @param radius Double
     * @param completionHandler (json: JSON) -> Void
     */
    func getUser(location location: CLLocation, radius: Double, completionHandler: (json: JSON) -> Void) {
        if radius <= 0 { return }

        let request = NSMutableURLRequest(
            URL: NSURL(
                URLString: "https://vasp.herokuapp.com/user",
                queries: [
                    "lat": "\(location.coordinate.latitude)",
                    "lng": "\(location.coordinate.longitude)",
                    "radius": "\(radius)",
                ]
            )!
        )

        // request
        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        AIRUserOperationQueue.defaultQueue().addOperation(operation)
    }

}

