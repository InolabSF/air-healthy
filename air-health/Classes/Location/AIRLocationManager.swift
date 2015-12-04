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
    static let ThresholdOfSensorNeighbor = 10000.0


    /// MARK: - property
    static let sharedInstance = AIRLocationManager()

    //var follower = Follower()
    var locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    var comfirmingCountToUpdateLastLocation = 0


    /// MARK: - initialization

    override init() {
        super.init()

        // location manager
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 8.0, *) { self.locationManager.requestAlwaysAuthorization() }
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

        self.lastLocation = nil
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
        let distance = (self.lastLocation != nil) ? newLocation.distanceFromLocation(self.lastLocation!) : newLocation.distanceFromLocation(oldLocation)
        // first location
        if self.lastLocation == nil {
            self.saveLocationName(location: newLocation)
            self.lastLocation = newLocation
            AIRLocation.save(location: newLocation)
        }
        // updating location
        else if distance >= AIRLocationManager.DistanceToUpdateLocation && // did move?
            newLocation.timestamp.compare(self.lastLocation!.timestamp) == NSComparisonResult.OrderedDescending { // is really new?
            if self.comfirmingCountToUpdateLastLocation >= AIRLocationManager.ComfirmingCountToUpdateLocation {
                self.saveLocationNameIfYouStay(newLocation: newLocation, oldLocation: self.lastLocation!)

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
    }

    /**
     * save location name if you stay
     * @param newLocation CLLocation
     **/
    private func saveLocationName(location location: CLLocation) {
        // already know the name
        let name = AIRLocationName.fetch(location: location)
        if name != nil { return }

        AIRGoogleMapClient.sharedInstance.getLocatoinNearBySearch(
            location: location,
            completionHandler: { (json) in
                if json["status"].string != AIRGoogleMap.Statuses.OK { return }
                AIRLocationName.save(json: json)
            }
        )
    }

    /**
     * save location name if you stay
     * @param newLocation CLLocation
     * @param oldLocation CLLocation
     **/
    private func saveLocationNameIfYouStay(newLocation newLocation: CLLocation, oldLocation: CLLocation) {
        // stay more than AIRLocationManager.ThresholdOfTimeIntervalToStop seconds
        if newLocation.timestamp.timeIntervalSinceDate(oldLocation.timestamp) < AIRLocationManager.ThresholdOfTimeIntervalToStop { return }
        // distance between 2 places are less than AIRLocationManager.ThresholdOfDistanceToStop meters
        if newLocation.distanceFromLocation(oldLocation) > AIRLocationManager.ThresholdOfDistanceToStop { return }

        self.saveLocationName(location: oldLocation)
    }

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
            if #available(iOS 8.0, *) { self.locationManager.requestAlwaysAuthorization() }
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
