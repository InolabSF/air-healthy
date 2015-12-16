import CoreLocation


/// MARK: - AIRSensorManager
class AIRSensorManager: NSObject {

    /// MARK: - constant
    static let Basement_1 =                     1.5
    static let Basement_2 =                     2.0
    //static let WHOBasementOzone_S_1 =           75.0
    //static let WHOBasementOzone_S_2 =           100.0
    //static let WHOBasementSO2_1 =               350.0
    //static let WHOBasementSO2_2 =               500.0
    static let WHOBasementOzone_S_1 =           50.0
    static let WHOBasementOzone_S_2 =           55.0
    static let WHOBasementSO2_1 =               310.0
    static let WHOBasementSO2_2 =               335.0

    static let DaysAgo =                        3


    /// MARK: - property
    static let sharedInstance = AIRSensorManager()


    /// MARK: - class method

    /**
     * return sensorBasements
     * @return sensorBasements [Double]
     **/
    class func sensorBasements() -> [Double] {
        return [Basement_1, Basement_2]
    }

    /**
     * return sensorBasements
     * @param name sensor's name
     * @return sensorBasements [Double]
     **/
    class func sensorBasements(name name: String) -> [Double] {
        if name == "SO2" { return [AIRSensorManager.WHOBasementSO2_1, AIRSensorManager.WHOBasementSO2_2] }
        if name == "Ozone_S" { return [AIRSensorManager.WHOBasementOzone_S_1, AIRSensorManager.WHOBasementOzone_S_2] }
        return [0.001]
    }

    /**
     * average sensor value at the location
     * @param name String
     * @param date NSDate
     * @param location CLLocation
     * @return Double
     **/
    class func averageSensorValue(name name: String, date: NSDate, location: CLLocation) -> Double {
        // sensor data from 100 meter x 100 meter rect
        let latOffset = AIRLocation.degree(meter: AIRLocationManager.ThresholdOfAverageSensorNeighbor, latlng: "lat", location: location)
        let lngOffset = AIRLocation.degree(meter: AIRLocationManager.ThresholdOfAverageSensorNeighbor, latlng: "lng", location: location)
        let southWest = CLLocation(
            latitude: location.coordinate.latitude - latOffset,
            longitude: location.coordinate.longitude - lngOffset
        )
        let northEast = CLLocation(
            latitude: location.coordinate.latitude + latOffset,
            longitude: location.coordinate.longitude + lngOffset
        )
        let sensors = AIRSensor.fetch(name: name, date: date, southWest: southWest, northEast: northEast)
        let count = sensors.count
        if count == 0 { return 0.0 }

        var sumValue: Double = 0
        for sensor in sensors {
            sumValue += sensor.value.doubleValue
        }
        return (sumValue / Double(count))
    }

    /**
     * average sensor values at the locations
     * @param name String
     * @param date NSDate
     * @param locations CLLocation
     * @return [Double]
     **/
    class func averageSensorValues(name name: String, date: NSDate, locations: [CLLocation]) -> [Double] {
        let southWest = AIRLocation.southWest(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfAverageSensorNeighbor)
        let northEast = AIRLocation.northEast(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfAverageSensorNeighbor)

        // average values
        var values: [Double] = []
        let allSensors = AIRSensor.fetch(name: name, date: date, southWest: southWest, northEast: northEast)
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            let latOffset = AIRLocation.degree(meter: AIRLocationManager.ThresholdOfAverageSensorNeighbor, latlng: "lat", location: location)
            let lngOffset = AIRLocation.degree(meter: AIRLocationManager.ThresholdOfAverageSensorNeighbor, latlng: "lng", location: location)
            let minLat = location.coordinate.latitude - latOffset
            let maxLat = location.coordinate.latitude + latOffset
            let minLng = location.coordinate.longitude - lngOffset
            let maxLng = location.coordinate.longitude + lngOffset
            let sensors = allSensors.filter( { (sensor: AIRSensor) -> Bool in
                let lat = sensor.lat.doubleValue
                let lng = sensor.lng.doubleValue
                return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng
            })

            var sum = 0.0
            for sensor in sensors { sum += sensor.value.doubleValue }
            let average = (sensors.count > 0) ? sum / Double(sensors.count) : 0

            values.append(average)
        }
        return values
    }

    /**
     * return sensor color
     * @param sensor AIRSensor
     * @return UIColor or nil
     **/
    class func sensorColor(sensor sensor: AIRSensor) -> UIColor {
        let value = sensor.value.doubleValue
        return AIRSensorManager.sensorColor(value: value, sensorBasements: AIRSensorManager.sensorBasements(name: sensor.name))
    }

    /**
     * return sensor color
     * @param sensor AIRSensor
     * @return UIColor or nil
     **/
    class func sensorCircleColor(sensor sensor: AIRSensor) -> UIColor? {
        let value = sensor.value.doubleValue
        let sensorBasements = AIRSensorManager.sensorBasements(name: sensor.name)
        if value < sensorBasements[0] {
            return nil
        }
        else if value < sensorBasements[1] {
            return UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        }
        return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)

    }

    /**
     * return sensor color
     * @param value Double
     * @param sensorBasements [Double]
     * @return UIColor or nil
     **/
    class func sensorColor(value value: Double, sensorBasements: [Double]) -> UIColor {
        if value < sensorBasements[0] {
            //return nil
            return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        }
        else if value < sensorBasements[1] {
            return UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        }
        return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    }

    /**
     * return sensor color
     * @param pass locations you passed
     * @param intervalFromStart Double
     * @param averageSensorValues [Double]
     * @param sensorBasements [Double]
     * @return UIColor
     **/
    class func sensorColor(passes passes: [CLLocation], intervalFromStart: Double, averageSensorValues: [Double], sensorBasements: [Double]) -> UIColor {
        if passes.count == 0 { return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0) }
        let date = passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)
        for var i = 1; i < passes.count; i++ {
            let start = passes[i-1]
            let end = passes[i]

            // marker
            if date.compare(start.timestamp) != .OrderedAscending && date.compare(end.timestamp) != .OrderedDescending {
                let value = (averageSensorValues[i-1] + averageSensorValues[i]) / 2.0
                if value < sensorBasements[0] {
                    return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
                }
                else if value < sensorBasements[1] {
                    return UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
                }
                else {
                    return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
                }
            }
        }
        return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
    }

    /**
     * return sensor values per minutes
     * @param pass locations you passed
     * @param averageSensorValues [Double]
     * @param sensorBasements [Double]
     * @return sensor values per minutes [Double]
     **/
    class func valuesPerMinute(passes passes: [CLLocation], averageSensorValues: [Double], sensorBasements: [Double]) -> [Double] {
        if passes.count == 0 { return [0.0] }
        let allMinutes = Int(passes.last!.timestamp.timeIntervalSinceDate(passes.first!.timestamp) / 60)

        var values: [Double] = []
        for var i = 0; i <= allMinutes; i++ { values.append(0.0) }

        for var i = 0; i < passes.count-1; i++ {
            let value = averageSensorValues[i]

            let startLocation = passes[i]
            let endLocation = passes[i+1]

            let startMinute = startLocation.timestamp.timeIntervalSinceDate(passes[0].timestamp) / 60.0
            let endMinute = endLocation.timestamp.timeIntervalSinceDate(passes[0].timestamp) / 60.0
            let start = Int(startMinute)
            let end = Int(endMinute)
            for var j = start; j < end; j++ {
                values[j] = value
            }
            values[start] += (Double(start+1) - startMinute) * value
            values[end] += (endMinute - Double(end)) * value
        }
        return values
    }


    /// MARK: - initialization

    override init() {
        super.init()
    }


    /// MARK: - public api

    /**
     * save demo data
     **/
    func saveDemoData() {
        //let path = NSBundle.mainBundle().pathForResource("vasp", ofType: "csv")!
        let path = NSBundle.mainBundle().pathForResource("vasp_mgpqm_0.2mile", ofType: "csv")!

        let error: NSErrorPointer = nil
        if let csv = CSV(contentsOfFile: path, error: error) {
            var json: [JSON] = []

            let rows = csv.rows
            for var i = 0; i < rows.count; i++ {
                json.append([
                    //"time" : rows[i]["time"]!,
                    "Ozone_S" : rows[i]["Ozone_S"]!,
                    "SO2" : rows[i]["SO2"]!,
                    //"latitude" : rows[i]["latitude"]!,
                    //"longitude" : rows[i]["longitude"]!,
                    "south" : rows[i]["south"]!,
                    "north" : rows[i]["north"]!,
                    "west" : rows[i]["west"]!,
                    "east" : rows[i]["east"]!,
                ])
            }
            AIRSensor.save(json: JSON(json))
        }
    }


    /// MARK: - private api

}
