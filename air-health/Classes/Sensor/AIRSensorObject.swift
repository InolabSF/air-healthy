/// MARK: - AIRSensorObject
class AIRSensorObject {

    /// MARK: - property
    var value: NSNumber = 0
    var lat: NSNumber = 0
    var lng: NSNumber = 0
    var name: String = ""
    var timestamp: NSDate = NSDate()


    /// MARK: - class method

    /**
     * return [AIRSensorObject]
     * @param json JSON
     * @return [AIRSensorObject]
     **/
    class func sensorObjects(json json: JSON) -> [AIRSensorObject] {
        var sensorObjects: [AIRSensorObject] = []

        let sensors = json.arrayValue
        if sensors.count == 0 { return sensorObjects }

        let names = ["UV", "NO2","PM25", "CO", "SO2", "Ozone_S",]
        for s in sensors {
            for name in names {
                let sensor = AIRSensorObject()

                sensor.value = s[name.lowercaseString].numberValue
                sensor.lat = s["lat"].numberValue
                sensor.lng = s["lng"].numberValue

                sensor.name = name
                sensor.timestamp = NSDate().air_daysAgo(days: 1)!
                sensorObjects.append(sensor)
            }
        }

        return sensorObjects
    }

}
