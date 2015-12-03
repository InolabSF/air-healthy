import CoreLocation


/// MARK: - AIRSensorManager
class AIRSensorManager: NSObject {

    /// MARK: - constant
    static let WHOBasementOzone_S_1 =           80.0
    static let WHOBasementOzone_S_2 =           100.0
    static let WHOBasementSO2_1 =               350.0
    static let WHOBasementSO2_2 =               500.0

//    static let WHOBasementOzone_S_1 =           48.5
//    static let WHOBasementOzone_S_2 =           49.0
//    static let WHOBasementSO2_1 =               292.0
//    static let WHOBasementSO2_2 =               294.0

    static let DaysAgo =                        3


    /// MARK: - property
    static let sharedInstance = AIRSensorManager()


    /// MARK: - class method

    /**
     * average sensor value at the location
     * @param name String
     * @param date NSDate
     * @param location CLLocation
     * @return Double
     **/
    class func averageSensorValue(name name: String, date: NSDate, location: CLLocation) -> Double {
        // sensor data from 100 meter x 100 meter rect
        let latOffset = AIRLocation.degree(meter: AIRLocationManager.ThresholdOfNeighbor, latlng: "lat", location: location)
        let lngOffset = AIRLocation.degree(meter: AIRLocationManager.ThresholdOfNeighbor, latlng: "lng", location: location)
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

//    /**
//     * location is healthy?
//     * @param name String
//     * @param date NSDate
//     * @param location CLLocation
//     * @return Bool
//     **/
//    class func locationIsHealthy(name name: String, date: NSDate, location: CLLocation) -> Bool {
//        // compare sensor data to WHO basement
//        let averageValue = AIRSensorManager.averageSensorValue(name: name, date: date, location: location)
//        let WHOBasements = [
//            "Ozone_S": AIRSensorManager.WHOBasementOzone_S,
//            "SO2": AIRSensorManager.WHOBasementSO2,
//        ]
//        let basement = WHOBasements[name]
//        if basement == nil { return true }
//        //AIRLOG(averageValue)
//        return (averageValue < basement)
//
//    }

    /**
     * average sensor values at the locations
     * @param name String
     * @param date NSDate
     * @param locations CLLocation
     * @return [Double]
     **/
    class func averageSensorValues(name name: String, date: NSDate, locations: [CLLocation]) -> [Double] {
        let southWest = AIRLocation.southWest(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfNeighbor)
        let northEast = AIRLocation.northEast(locations: locations, offsetMeters: AIRLocationManager.ThresholdOfNeighbor)

        // average values
        var values: [Double] = []
        let allSensors = AIRSensor.fetch(name: name, date: date, southWest: southWest, northEast: northEast)
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            let latOffset = AIRLocation.degree(meter: AIRLocationManager.ThresholdOfNeighbor, latlng: "lat", location: location)
            let lngOffset = AIRLocation.degree(meter: AIRLocationManager.ThresholdOfNeighbor, latlng: "lng", location: location)
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
     * return sensor color
     * @param value Double
     * @param sensorBasements [Double]
     * @return UIColor
     **/
    class func sensorColor(value value: Double, sensorBasements: [Double]) -> UIColor {
        if value < sensorBasements[0] {
            return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        }
        else if value < sensorBasements[1] {
            return UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        }
        return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    }


//    /**
//     * return sensor values per minutes
//     * @param pass locations you passed
//     * @param averageSensorValues [Double]
//     * @param sensorBasements [Double]
//     * @return sensor values per minutes [CGFloat]
//     **/
//    class func valuesPerMinute(passes passes: [CLLocation], averageSensorValues: [Double], sensorBasements: [Double]) -> [CGFloat] {
//        if passes.count == 0 { return [0.0] }
//        let allMinutes = Int(passes.last!.timestamp.timeIntervalSinceDate(passes.first!.timestamp) / 60)
//
//        var values: [CGFloat] = []
//        for var i = 0; i <= allMinutes; i++ { values.append(0.0) }
//
//        for var i = 0; i < passes.count-1; i++ {
//            let value = CGFloat(averageSensorValues[i])
//
//            let startLocation = passes[i]
//            let endLocation = passes[i+1]
//
//            let startMinute = startLocation.timestamp.timeIntervalSinceDate(passes[0].timestamp) / 60.0
//            let endMinute = endLocation.timestamp.timeIntervalSinceDate(passes[0].timestamp) / 60.0
//            let start = Int(startMinute)
//            let end = Int(endMinute)
//            for var i = start+1; i < end; i++ {
//                values[i] = value
//            }
//            values[start] += CGFloat(Double(start+1) - startMinute) * value
//            values[end] += CGFloat(endMinute - Double(end)) * value
//        }
//
//        return values
//    }
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
            for var i = start+1; i < end; i++ {
                values[i] = value
            }
            values[start] += (Double(start+1) - startMinute) * value
            values[end] += (endMinute - Double(end)) * value
        }
        return values
    }


    /**
     * locations are healthy?
     * @param name String
     * @param date NSDate
     * @param locations [CLLocation]
     * @return [Bool]
     **/
//    class func locationsAreHealthy(name name: String, date: NSDate, locations: [CLLocation]) -> [Bool] {
//        // compare sensor data to WHO basement
//        let averageValues = AIRSensorManager.averageSensorValues(name: name, date: date, locations: locations)
//        let WHOBasements = [
//            "Ozone_S": AIRSensorManager.WHOBasementOzone_S,
//            "SO2": AIRSensorManager.WHOBasementSO2,
//        ]
//
//        var areHealthy: [Bool] = []
//
//        let basement = WHOBasements[name]
//        if basement == nil {
//            for var i = 0; i < locations.count; i++ { areHealthy.append(true) }
//        }
//        for var i = 0; i < averageValues.count; i++ {
//            areHealthy.append(averageValues[i] < basement)
//        }
//        return areHealthy
//    }

    /**
     * return health evaluation
     * @param name String
     * @param date NSDate
     * @return percentage 0~100(Double)
     **/
//    class func healthEvaluation(name name: String, date: NSDate) -> Double {
//        let locations = AIRLocation.fetch(date: date)
//        if locations.count < 2 { return 100 }
//
//        // time interval between start location and end location
//        let allInterval = locations[locations.count-1].timestamp.timeIntervalSinceDate(locations[0].timestamp)
//
//        var centerLocations: [CLLocation] = []
//        var intervals: [Double] = []
//
//        for var i = 1; i < locations.count; i++ {
//            let start = locations[i-1]
//            let end = locations[i]
//
//            // location is healthy?
//            let center = CLLocation(
//                latitude: (start.coordinate.latitude + end.coordinate.latitude) / 2.0,
//                longitude: (start.coordinate.longitude + end.coordinate.longitude) / 2.0
//            )
//            centerLocations.append(center)
//
//            // if healthy
//            let interval = end.timestamp.timeIntervalSinceDate(start.timestamp) // time interval between start and end
//            intervals.append(interval)
//        }
//
//        var healthValue = 0.0
//        let areHealthy = AIRSensorManager.locationsAreHealthy(name: name, date: date, locations: centerLocations)
//        for var i = 0; i < centerLocations.count; i++ {
//            let isHealthy = areHealthy[i]
//            if !isHealthy { continue }
//            let interval = intervals[i]
//            healthValue += Double(interval / allInterval) * 100.0
//        }
//        return healthValue
//    }


    /// MARK: - initialization

    override init() {
        super.init()
    }


    /// MARK: - public api

    /**
     * save demo data
     **/
    func saveDemoData() {
        let path = NSBundle.mainBundle().pathForResource("vasp", ofType: "csv")!
        let error: NSErrorPointer = nil
        if let csv = CSV(contentsOfFile: path, error: error) {
            var json: [JSON] = []

            let rows = csv.rows
            for var i = 0; i < rows.count; i++ {
                json.append([
                    "CO" : rows[i]["CO"]!,
                    "SO2" : rows[i]["SO2"]!,
                    "Ozone_S" : rows[i]["Ozone_S"]!,
                    "latitude" : rows[i]["latitude"]!,
                    "longitude" : rows[i]["longitude"]!,
                    "time" : rows[i]["time"]!,
                ])
            }
            AIRSensor.save(json: JSON(json))
        }
    }


    /// MARK: - private api

}
