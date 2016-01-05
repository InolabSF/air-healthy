import CoreLocation


/// MARK: - AIRLocationManager
class AIRLocationManager: NSObject {

    /// MARK: - constant
    static let IntervalToStartUpdatingLocation = 3.0 // seconds to update location
    static let DistanceToUpdateLocation: CLLocationDistance = 20.0 // distance to update location
    static let ComfirmingCountToUpdateLocation = 3 // comfirming count to update location

    static let ThresholdOfTimeIntervalToStop: NSTimeInterval = 300
    static let ThresholdOfDistanceToStop: CLLocationDistance = 200
    static let ThresholdOfNeighbor = 50.0
    static let ThresholdOfAverageSensorNeighbor = 200.0
    static let ThresholdOfSensorNeighbor = 50000.0


    /// MARK: - property
    static let sharedInstance = AIRLocationManager()

    //var follower = Follower()
    var locationManager = CLLocationManager()
//    var lastLocation: CLLocation? {
//        didSet {
//            if self.lastLocation == nil { return }
//            // notification
//            NSNotificationCenter.defaultCenter().postNotificationName(
//                AIRNotificationCenter.UpdateLocation,
//                object: nil,
//                userInfo: ["location":self.lastLocation!]
//            )
//        }
//    }
    var comfirmingCountToUpdateLastLocation = 0


    /// MARK: - initialization

    override init() {
        super.init()

        // location manager
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        if #available(iOS 9.0, *) { self.locationManager.allowsBackgroundLocationUpdates = true }
        self.locationManager.distanceFilter = 100
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
    }


    /// MARK: - public api

    /**
     * start updating location
     **/
    func startUpdatingLocation() {
        let GPSIsOff = NSUserDefaults().boolForKey(AIRUserDefaults.GPSIsOff)
        if GPSIsOff { return }

//        self.lastLocation = nil
        self.comfirmingCountToUpdateLastLocation = 0
        self.locationManager.startUpdatingLocation()

//        self.follower.delegate = self
//        self.follower.beginRouteTracking()
    }

    /**
     * stop updating location
     **/
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()

//        self.follower.endRouteTracking()
    }

    /**
     * save location name
     * @param location CLLocation
     * @param completionHandler called when location name is saved
     **/
    func saveLocationName(location location: CLLocation, completionHandler: () -> Void) {
        AIRGoogleMapClient.sharedInstance.getLocatoinNearBySearch(
            location: location,
            completionHandler: { (json) in
                if json["status"].string != AIRGoogleMap.Statuses.OK { return }
                AIRLocationName.save(json: json)
                completionHandler()
            }
        )
    }

    /**
     * save demo data
     **/
    func saveDemoData() {
        let path = NSBundle.mainBundle().pathForResource("ZAIRLOCATION", ofType: "csv")!
        let error: NSErrorPointer = nil
        if let csv = CSV(contentsOfFile: path, error: error) {
            var locations: [CLLocation] = []

            let rows = csv.rows
            for var i = 0; i < rows.count; i++ {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

                let location = CLLocation(
                    coordinate: CLLocationCoordinate2D(latitude: Double(rows[i]["lat"]!)!, longitude: Double(rows[i]["lng"]!)!),
                    altitude: Double(rows[i]["altitude"]!)!,
                    horizontalAccuracy: Double(rows[i]["hAccuracy"]!)!,
                    verticalAccuracy: Double(rows[i]["vAccuracy"]!)!,
                    course: Double(rows[i]["course"]!)!,
                    speed: Double(rows[i]["speed"]!)!,
                    timestamp: dateFormatter.dateFromString(rows[i]["timestamp"]!)!.air_daysAgo(days: -1)!
                )
                locations.append(location)
            }
            AIRLocation.save(locations: locations)
        }
    }


    /// MARK: - private api

    /**
     * update location
     * @param newLocation CLLocation
     * @param oldLocation CLLocation
     **/
    private func updateLocation(newLocation newLocation: CLLocation, oldLocation: CLLocation) {
        let lastLocation = AIRLocation.fetchLast(date: NSDate())
        let distance = (lastLocation != nil) ? newLocation.distanceFromLocation(lastLocation!) : newLocation.distanceFromLocation(oldLocation)

        // first location
        if lastLocation == nil {
            AIRLocation.save(location: newLocation)
            self.postPollutedNotification(location: newLocation)
            AIRUserClient.sharedInstance.postUser(location: newLocation, completionHandler: { (json) in })
        }
        // updating location
        else if distance >= AIRLocationManager.DistanceToUpdateLocation && // did move?
            newLocation.timestamp.compare(lastLocation!.timestamp) == NSComparisonResult.OrderedDescending { // is really new?
            if self.comfirmingCountToUpdateLastLocation >= AIRLocationManager.ComfirmingCountToUpdateLocation {
                AIRLocation.save(location: newLocation)
                self.postPollutedNotification(location: newLocation)
                AIRUserClient.sharedInstance.postUser(location: newLocation, completionHandler: { (json) in })
                self.comfirmingCountToUpdateLastLocation = 0
            }
            else { self.comfirmingCountToUpdateLastLocation += 1 }
        }
        else { self.comfirmingCountToUpdateLastLocation = 0 }

        let GPSIsOff = NSUserDefaults().boolForKey(AIRUserDefaults.GPSIsOff)
        if GPSIsOff { return }
        self.locationManager.startUpdatingLocation()

/*
        let distance = (self.lastLocation != nil) ? newLocation.distanceFromLocation(self.lastLocation!) : newLocation.distanceFromLocation(oldLocation)
        // first location
        if self.lastLocation == nil {
            self.lastLocation = newLocation
            AIRLocation.save(location: newLocation)
        }
        // updating location
        else if distance >= AIRLocationManager.DistanceToUpdateLocation && // did move?
            newLocation.timestamp.compare(self.lastLocation!.timestamp) == NSComparisonResult.OrderedDescending { // is really new?
            if self.comfirmingCountToUpdateLastLocation >= AIRLocationManager.ComfirmingCountToUpdateLocation {

                self.lastLocation = newLocation
                AIRLocation.save(location: newLocation)
                self.comfirmingCountToUpdateLastLocation = 0
            }
            else { self.comfirmingCountToUpdateLastLocation += 1 }
        }
        else { self.comfirmingCountToUpdateLastLocation = 0 }

        let GPSIsOff = NSUserDefaults().boolForKey(AIRUserDefaults.GPSIsOff)
        if GPSIsOff { return }
        self.locationManager.startUpdatingLocation()
//        self.follower.endRouteTracking()
//        self.follower.beginRouteTracking()
*/
    }

    /**
     * post polluted location warning notification
     * @param location CLLocation
     **/
    private func postPollutedNotification(location location: CLLocation) {
        func postPollutedNotification(location location: CLLocation, name: String) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let time = dateFormatter.stringFromDate(NSDate())

                let localNotification = UILocalNotification()
                localNotification.alertBody = "BAD AIR WARNING!\n\(name) \(time)\nRecommended you to stay indoor."
                localNotification.soundName = UILocalNotificationDefaultSoundName
                localNotification.timeZone = NSTimeZone.defaultTimeZone()
                //localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
                UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
            })
        }

        let today = NSDate()
        let o3 = AIRSensorManager.averageSensorValue(name: "Ozone_S", date: today, location: location) / AIRSensorManager.WHOBasementOzone_S_2
        let so2 = AIRSensorManager.averageSensorValue(name: "SO2", date: today, location: location) / AIRSensorManager.WHOBasementSO2_2
        let value = (o3 + so2)
        if value < AIRSensorManager.Basement_2 { return }

        AIRBadAirLocation.save(location: location)

        let name = AIRLocationName.fetch(location: location)
        if name == nil {
            AIRLocationManager.sharedInstance.saveLocationName(
                location: location,
                completionHandler: { () -> Void in
                    let n = AIRLocationName.fetch(location: location)
                    if n != nil { postPollutedNotification(location: location, name: n!.name) }
                }
            )
        }
        else {
            postPollutedNotification(location: location, name: name!.name)
        }
    }

    /**
     * save location name if you stay
     * @param newLocation CLLocation
     * @param oldLocation CLLocation
     **/
/*
    private func saveLocationNameIfYouStay(newLocation newLocation: CLLocation, oldLocation: CLLocation) {
        // stay more than AIRLocationManager.ThresholdOfTimeIntervalToStop seconds
        if newLocation.timestamp.timeIntervalSinceDate(oldLocation.timestamp) < AIRLocationManager.ThresholdOfTimeIntervalToStop { return }
        // distance between 2 places are less than AIRLocationManager.ThresholdOfDistanceToStop meters
        if newLocation.distanceFromLocation(oldLocation) > AIRLocationManager.ThresholdOfDistanceToStop { return }

        self.saveLocationName(location: oldLocation)
    }
*/
}


/// MARK: - CLLocationManagerDelegate
extension AIRLocationManager: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(AIRLocationManager.IntervalToStartUpdatingLocation * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            { (void) in
                self.updateLocation(newLocation: newLocation, oldLocation: oldLocation)
            }
        )
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let GPSIsOff = NSUserDefaults().boolForKey(AIRUserDefaults.GPSIsOff)
        if GPSIsOff { return }

        self.locationManager.startUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}


/*
/// MARK: - FollowerDelegate
extension AIRLocationManager: FollowerDelegate {

    func followerDidUpdate(follower: Follower) {
        let location = self.follower.routeLocations.lastObject as! CLLocation
        if self.lastLocation != nil {
            self.updateLocation(newLocation: location, oldLocation: self.lastLocation!)
        }
        self.lastLocation = location
    }

}
*/

