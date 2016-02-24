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
     * @param name String
     * @return [AIRSensorObject]
     **/
    class func sensorObjects(json json: JSON, name: String) -> [AIRSensorObject] {
        var sensorObjects: [AIRSensorObject] = []

        let sensors = json.arrayValue
        if sensors.count == 0 { return sensorObjects }

        let names = ["UV", "NO2","PM25", "CO", "SO2", "Ozone_S",]
        for s in sensors {
            for n in names {
                if n != name { continue }

                let sensor = AIRSensorObject()

                sensor.value = s[n.lowercaseString].numberValue
                sensor.lat = s["lat"].numberValue
                sensor.lng = s["lng"].numberValue

                sensor.name = n
                sensor.timestamp = NSDate().air_daysAgo(days: 1)!
                sensorObjects.append(sensor)
            }
        }

        return sensorObjects
    }

}
