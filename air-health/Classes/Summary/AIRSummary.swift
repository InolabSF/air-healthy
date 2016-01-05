/// MARK: - AIRSummaryDelegate
@objc protocol AIRSummaryDelegate {

    /**
     * called when summary calculation start
     * @param summary AIRSummary
     */
    func summaryCalculationDidStart(summary summary: AIRSummary)

    /**
     * called when summary calculation end
     * @param summary AIRSummary
     */
    func summaryCalculationDidEnd(summary summary: AIRSummary)

}


/// MARK: - AIRSummary
class AIRSummary: NSObject {

    static let sharedInstance = AIRSummary()

    /// MARK: - property

    weak var delegate: AnyObject?

    var passes: [CLLocation] = []               // location you passed
    var values: [Double] = []                   // summary values per minute
    var sensors: [AIRSensor] = []               // sensor datas
    var users: [AIRUser] = []                   // user datas

    var SO2ValuePerMinutes: [Double] = []       // SO2 value per minutes
    var O3ValuePerMinutes: [Double] = []        // O3 value per minutes


    /// MARK: - initialization
    override init() {
        super.init()

        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("getSensorsNotificatoin:"),
            name: AIRNotificationCenter.UpdateSensorValues,
            object: nil
        )

        // get new sensor values
        self.getSensorsFromServer()
        // get user datas from server
        self.getUsersFromServer()
    }

    /// MARK: - destruction

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - notification

    /**
     * get sensor datas
     * @param notification NSNotification
     **/
    func getSensorsNotificatoin(notificatoin: NSNotification) {
        // get new sensor values
        self.getSensorsFromServer()
        // get user datas from server
        self.getUsersFromServer()
    }


    /// MARK: - private api

    /**
     * get sensor datas from server
     **/
    func getSensorsFromServer() {
        AIRSensorClient.sharedInstance.getSensorValues(
            locations: self.passes,
            completionHandler: { [unowned self] (json: JSON) -> Void in
                AIRSensor.deleteAll()
                AIRSensor.save(json: json)
                self.setSensorValues()
            }
        )

    }

    /**
     * get user datas from server
     **/
    func getUsersFromServer() {
        if passes.count <= 0 { return }

        let location = passes.last
        AIRUserClient.sharedInstance.getUser(location: location!, radius: 5.0, completionHandler: { [unowned self] (json) in
                self.users = AIRUser.users(json: json)
            }
        )
    }

    /**
     * set sensor datas
     **/
    private func setSensorValues() {
        dispatch_async(
            dispatch_get_main_queue(), { [unowned self] () in

            if self.delegate != nil {
                (self.delegate as! AIRSummaryDelegate).summaryCalculationDidStart(summary: self)
                AIRLOG("summary calculation started")
            }

        })

        // calculate summary
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) / 10.0)),
            dispatch_get_main_queue(), { [unowned self] () in


            let today = NSDate()

            // passes and sensor datas
            self.passes  = AIRLocation.fetch(date: today)


            // sensors
            let southWest = AIRLocation.southWest(locations: self.passes, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
            let northEast = AIRLocation.northEast(locations: self.passes, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
            self.sensors = AIRSensor.fetch(date: today, southWest: southWest, northEast: northEast)

            // values
            self.SO2ValuePerMinutes = AIRSensorManager.valuesPerMinute(
                passes: self.passes,
                averageSensorValues: AIRSensorManager.averageSensorValues(name: "SO2", date: today, locations: self.passes),
                sensorBasements: AIRSensorManager.sensorBasements(name: "SO2")
            )
            self.O3ValuePerMinutes = AIRSensorManager.valuesPerMinute(
                passes: self.passes,
                averageSensorValues: AIRSensorManager.averageSensorValues(name: "Ozone_S", date: today, locations: self.passes),
                sensorBasements: AIRSensorManager.sensorBasements(name: "Ozone_S")
            )
            self.values = []
            for var i = 0; i < self.SO2ValuePerMinutes.count; i++ {
                let so2 = abs(self.SO2ValuePerMinutes[i] / AIRSensorManager.WHOBasementSO2_2)
                let o3 = abs(self.O3ValuePerMinutes[i] / AIRSensorManager.WHOBasementOzone_S_2)
                let value = so2 + o3
                self.values.append(value)
            }


            AIRLOG("summary calculation ended")
            if self.delegate != nil {
                (self.delegate as! AIRSummaryDelegate).summaryCalculationDidEnd(summary: self)
            }

            }
        )
    }
}
