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
    //var users: [AIRUser] = []                   // user datas

    var SO2ValuePerMinutes: [Double] = []       // SO2 value per minutes
    var O3ValuePerMinutes: [Double] = []        // O3 value per minutes
    var COValuePerMinutes: [Double] = []        // CO value per minutes
    var UVValuePerMinutes: [Double] = []        // UV value per minutes
    var NO2ValuePerMinutes: [Double] = []       // NO2 value per minutes
    var PM25ValuePerMinutes: [Double] = []      // PM25 value per minutes


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

        self.passes = AIRLocation.fetch(date: NSDate())
        // get new sensor values
        self.getSensorsFromServer()
        // get user datas from server
        //self.getUsersFromServer()
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
        //self.getUsersFromServer()
    }


    /// MARK: - public api

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

//    /**
//     * get user datas from server
//     **/
//    func getUsersFromServer() {
//        if passes.count <= 0 { return }
//
//        let location = passes.last
//        AIRUserClient.sharedInstance.getUser(location: location!, radius: 5.0, completionHandler: { [unowned self] (json) in
//                self.users = AIRUser.users(json: json)
//            }
//        )
//    }

    /**
     * set sensor datas
     **/
    func setSensorValues() {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] () in
            if self.delegate != nil {
                (self.delegate as! AIRSummaryDelegate).summaryCalculationDidStart(summary: self)
            }
        })

        // calculate summary
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) / 10.0)),
            dispatch_get_main_queue(),
            { [unowned self] () in


                let today = NSDate()

                // passes and sensor datas
                self.passes = AIRLocation.fetch(date: today)

                // sensors
                self.sensors = AIRSensor.fetch()
/*
                let southWest = AIRLocation.southWest(locations: self.passes, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
                let northEast = AIRLocation.northEast(locations: self.passes, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
                self.sensors = AIRSensor.fetch(date: today, southWest: southWest, northEast: northEast)
*/

                // values
                self.SO2ValuePerMinutes = AIRSensorManager.valuesPerMinute(
                    passes: self.passes,
                    averageSensorValues: AIRSensorManager.averageSensorValues(chemical: "SO2", date: today, locations: self.passes),
                    sensorBasements: AIRSensorManager.sensorBasements(chemical: "SO2")
                )
                self.O3ValuePerMinutes = AIRSensorManager.valuesPerMinute(
                    passes: self.passes,
                    averageSensorValues: AIRSensorManager.averageSensorValues(chemical: "Ozone_S", date: today, locations: self.passes),
                    sensorBasements: AIRSensorManager.sensorBasements(chemical: "Ozone_S")
                )
                self.NO2ValuePerMinutes = AIRSensorManager.valuesPerMinute(
                    passes: self.passes,
                    averageSensorValues: AIRSensorManager.averageSensorValues(chemical: "NO2", date: today, locations: self.passes),
                    sensorBasements: AIRSensorManager.sensorBasements(chemical: "NO2")
                )
                self.PM25ValuePerMinutes = AIRSensorManager.valuesPerMinute(
                    passes: self.passes,
                    averageSensorValues: AIRSensorManager.averageSensorValues(chemical: "PM25", date: today, locations: self.passes),
                    sensorBasements: AIRSensorManager.sensorBasements(chemical: "PM25")
                )
                self.COValuePerMinutes = AIRSensorManager.valuesPerMinute(
                    passes: self.passes,
                    averageSensorValues: AIRSensorManager.averageSensorValues(chemical: "CO", date: today, locations: self.passes),
                    sensorBasements: AIRSensorManager.sensorBasements(chemical: "CO")
                )
                self.UVValuePerMinutes = AIRSensorManager.valuesPerMinute(
                    passes: self.passes,
                    averageSensorValues: AIRSensorManager.averageSensorValues(chemical: "UV", date: today, locations: self.passes),
                    sensorBasements: AIRSensorManager.sensorBasements(chemical: "UV")
                )

                self.values = []
                for var i = 0; i < self.SO2ValuePerMinutes.count; i++ {
                    let so2 = abs(self.SO2ValuePerMinutes[i] / AIRSensorManager.WHOBasementSO2_2)
                    let o3 = abs(self.O3ValuePerMinutes[i] / AIRSensorManager.WHOBasementOzone_S_2)
                    let co = abs(self.COValuePerMinutes[i] / AIRSensorManager.WHOBasementCO_2)
                    let no2 = abs(self.NO2ValuePerMinutes[i] / AIRSensorManager.WHOBasementNO2_2)
                    let pm25 = abs(self.PM25ValuePerMinutes[i] / AIRSensorManager.WHOBasementPM25_2)
                    let uv = abs(self.UVValuePerMinutes[i] / AIRSensorManager.WHOBasementUV_2)
                    let value = so2 + o3 + co + uv + no2 + pm25
                    self.values.append(value)
                }


                if self.delegate != nil {
                    (self.delegate as! AIRSummaryDelegate).summaryCalculationDidEnd(summary: self)
                }
            }
        )
    }
}
