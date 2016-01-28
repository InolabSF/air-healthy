import CoreLocation


/// MARK: - AIRLocationManager
class AIRLocationManager: NSObject {

    /// MARK: - constant
    //static let IntervalToStartUpdatingLocation = 10.0 // seconds to update location
    static let IntervalToStartUpdatingLocation = 3.0 // seconds to update location
    static let DistanceToUpdateLocation: CLLocationDistance = 50.0 // distance to update location
    //static let ComfirmingCountToUpdateLocation = 3 // comfirming count to update location
    static let ComfirmingCountToUpdateLocation = 5 // comfirming count to update location

    static let ThresholdOfTimeIntervalToStop: NSTimeInterval = 300
    static let ThresholdOfDistanceToStop: CLLocationDistance = 200
    static let ThresholdOfNeighbor = 50.0
    static let ThresholdOfAverageSensorNeighbor = 200.0
    static let ThresholdOfSensorNeighbor = 50000.0


    /// MARK: - property
    static let sharedInstance = AIRLocationManager()

    var locationManager = CLLocationManager()
    var timer : NSTimer?
    var comfirmingCountToUpdateLastLocation = 0

    var lastLocation: CLLocation? {
        get {
            return self.locationManager.location
        }
    }


    /// MARK: - initialization

    override init() {
        super.init()

        // location manager
        //self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if #available(iOS 9.0, *) { self.locationManager.allowsBackgroundLocationUpdates = true }
        self.locationManager.distanceFilter = 100
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
/*
        self.locationManager.allowDeferredLocationUpdatesUntilTraveled(
            distance: AIRLocationManager.DistanceToUpdateLocation,
            timeout: AIRLocationManager.IntervalToStartUpdatingLocation
        )
*/
    }


    /// MARK: - public api

    /**
     * start updating location
     **/
    func startUpdatingLocation() {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in

            let GPSIsOff = NSUserDefaults().boolForKey(AIRUserDefaults.GPSIsOff)
            if GPSIsOff {
                self.stopUpdatingLocation()
                return
            }

            //self.comfirmingCountToUpdateLastLocation = 0
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()

        })
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
                let dateFormatter = NSDateFormatter.air_dateFormatter()
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

        dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in

            let lastLocation = AIRLocation.fetchLast(date: NSDate())
            let distance = (lastLocation != nil) ? newLocation.distanceFromLocation(lastLocation!) : newLocation.distanceFromLocation(oldLocation)

            // first location
            if lastLocation == nil {
                AIRLocation.save(location: newLocation)
                //self.postPollutedNotification(location: newLocation)
                AIRUserClient.sharedInstance.postUser(location: newLocation, completionHandler: { (json) in })
            }
            // updating location
            else if distance >= AIRLocationManager.DistanceToUpdateLocation && // did move?
                newLocation.timestamp.compare(lastLocation!.timestamp) == NSComparisonResult.OrderedDescending { // is really new?

                if self.comfirmingCountToUpdateLastLocation >= AIRLocationManager.ComfirmingCountToUpdateLocation {
                    AIRLocation.save(location: newLocation)
                    //self.postPollutedNotification(location: newLocation)
                    AIRUserClient.sharedInstance.postUser(location: newLocation, completionHandler: { (json) in })
                }
                else { self.comfirmingCountToUpdateLastLocation += 1 }
            }
            else { self.comfirmingCountToUpdateLastLocation = 0 }

        })
    }
}


/// MARK: - CLLocationManagerDelegate
extension AIRLocationManager: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.updateLocation(newLocation: newLocation, oldLocation: oldLocation)

        dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in

            if self.timer != nil && self.timer!.valid {
                self.timer!.invalidate()
            }
            self.timer = NSTimer.scheduledTimerWithTimeInterval(
                AIRLocationManager.IntervalToStartUpdatingLocation,
                target: self,
                selector: Selector("startUpdatingLocation"),
                userInfo: nil,
                repeats: false
            )

        })

/*
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(AIRLocationManager.IntervalToStartUpdatingLocation * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            { [unowned self] () -> Void in
                self.updateLocation(newLocation: newLocation, oldLocation: oldLocation)
            }
        )
*/
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.startUpdatingLocation()
/*
        let GPSIsOff = NSUserDefaults().boolForKey(AIRUserDefaults.GPSIsOff)
        if GPSIsOff { return }
        self.locationManager.startUpdatingLocation()
*/
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
