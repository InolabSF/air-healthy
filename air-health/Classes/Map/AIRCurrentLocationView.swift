/// MARK: - AIRCurrentLocationView
class AIRCurrentLocationView: UIView {

    /// MARK: - constant


    /// MARK: - property

    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!


    /// MARK: - destruction

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setUp()
    }


    /// MARK: - event listener


    /// MARK: - notification

    /**
     * called when location is updated
     * @param notification NSNotification
     **/
    func updateLocation(notificatoin: NSNotification) {
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active { return }

        let userInfo = notificatoin.userInfo
        let location = userInfo!["location"] as! CLLocation

        let name = AIRLocationName.fetch(location: location)
        if name != nil {
            self.setCurrentLocation(location, name: name!)
        }
        else {
            AIRLocationManager.sharedInstance.saveLocationName(
                location: location,
                completionHandler: { [unowned self] () -> Void in
                    let n = AIRLocationName.fetch(location: location)
                    if n != nil { self.setCurrentLocation(location, name: n!) }
                }
            )
        }
    }


    /// MARK: - public api


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("updateLocation:"),
            name: AIRNotificationCenter.UpdateLocation,
            object: nil
        )
    }

    /**
     * set current location
     * @param location CLLocation
     * @param name String
     **/
    private func setCurrentLocation(location: CLLocation, name: AIRLocationName) {
        let today = NSDate()
        let o3 = AIRSensorManager.averageSensorValue(name: "Ozone_S", date: today, location: location) / AIRSensorManager.WHOBasementOzone_S_2
        let so2 = AIRSensorManager.averageSensorValue(name: "SO2", date: today, location: location) / AIRSensorManager.WHOBasementSO2_2
        let value = CGFloat(o3 + so2)
        if value < AIRSensorGraphView.Basement_1 {
            self.locationImageView.image = UIImage(named: "home_location_good")
            self.statusLabel.text = "Air Status: Good"
        }
        else if value < AIRSensorGraphView.Basement_2 {
            self.locationImageView.image = UIImage(named: "home_location_normal")
            self.statusLabel.text = "Air Status: Normal"
        }
        else {
            self.locationImageView.image = UIImage(named: "home_location_bad")
            self.statusLabel.text = "Air Status: Bad"
        }
        self.locationLabel.text = "\(name.name)"
    }

}
