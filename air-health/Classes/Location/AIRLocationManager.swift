import CoreLocation


/// MARK: - AIRLocationManager
class AIRLocationManager: NSObject {

    /// MARK: - constant
    static let IntervalToStartUpdatingLocation = 3.0 // seconds to update location
    static let DistanceToUpdateLocation: CLLocationDistance = 20.0 // distance to update location
    static let ComfirmingCountToUpdateLocation = 3 // comfirming count to update location


    /// MARK: - property
    static let sharedInstance = AIRLocationManager()

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
        self.lastLocation = nil
        self.comfirmingCountToUpdateLastLocation = 0

        self.locationManager.startUpdatingLocation()
    }

    /**
     * stop updating location
     **/
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()

/*
        AIRGoogleMapClient.sharedInstance.getLocatoinNearBySearch(
            location: newLocation,
            completionHandler: { (json) in
                AIRLOG("\(json)")
            }
        )
*/
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
            self.lastLocation = newLocation
            AIRLocation.save(location: newLocation)
        }
        // updating location
        else if distance >= AIRLocationManager.DistanceToUpdateLocation && // did move?
            newLocation.timestamp.compare(self.lastLocation!.timestamp) == NSComparisonResult.OrderedDescending // is really new?
        {
            if self.comfirmingCountToUpdateLastLocation >= AIRLocationManager.ComfirmingCountToUpdateLocation {
                self.lastLocation = newLocation
                AIRLocation.save(location: newLocation)
                self.comfirmingCountToUpdateLastLocation = 0
            }
            else { self.comfirmingCountToUpdateLastLocation += 1 }
        }
        else { self.comfirmingCountToUpdateLastLocation = 0 }

        self.locationManager.startUpdatingLocation()
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
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied {
            if #available(iOS 8.0, *) { self.locationManager.requestAlwaysAuthorization() }
        }
    }
}
