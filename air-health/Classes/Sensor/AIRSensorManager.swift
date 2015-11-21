import CoreLocation


/// MARK: - AIRSensorManager
class AIRSensorManager: NSObject {

    /// MARK: - constant
    static let WHOBasementOzone_S =             100.0
    static let WHOBasementSO2 =                 500.0
    //static let WHOBasementSO2 =                 362.0


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
        let latOffset = AIRLocation.degree(meter: 50, latlng: "lat", location: location)
        let lngOffset = AIRLocation.degree(meter: 50, latlng: "lng", location: location)
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
     * location is healthy?
     * @param name String
     * @param date NSDate
     * @param location CLLocation
     * @return Bool
     **/
    class func locationIsHealthy(name name: String, date: NSDate, location: CLLocation) -> Bool {
        // compare sensor data to WHO basement
        let averageValue = AIRSensorManager.averageSensorValue(name: name, date: date, location: location)
        let WHOBasements = [
            "Ozone_S": AIRSensorManager.WHOBasementOzone_S,
            "SO2": AIRSensorManager.WHOBasementSO2,
        ]
        let basement = WHOBasements[name]
        if basement == nil { return true }
        //AIRLOG(averageValue)
        return (averageValue < basement)

    }

    /**
     * average sensor values at the locations
     * @param name String
     * @param date NSDate
     * @param locations CLLocation
     * @return [Double]
     **/
    class func averageSensorValues(name name: String, date: NSDate, locations: [CLLocation]) -> [Double] {
        // get locations rect
        var minLat = 90.0
        var maxLat = -90.0
        var minLng = 180.0
        var maxLng = -180.0
        for location in locations {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            if minLat > lat { minLat = lat }
            if maxLat < lat { maxLat = lat }
            if minLng > lng { minLng = lng }
            if maxLng < lng { maxLng = lng }
        }
        var southWest = CLLocation(latitude: minLat, longitude: minLng)
        var northEast = CLLocation(latitude: maxLat, longitude: maxLng)
        var latOffset = AIRLocation.degree(meter: 50, latlng: "lat", location: southWest)
        var lngOffset = AIRLocation.degree(meter: 50, latlng: "lng", location: southWest)
        southWest = CLLocation(latitude: southWest.coordinate.latitude-latOffset, longitude: southWest.coordinate.longitude-lngOffset)
        latOffset = AIRLocation.degree(meter: 50, latlng: "lat", location: northEast)
        lngOffset = AIRLocation.degree(meter: 50, latlng: "lng", location: northEast)
        southWest = CLLocation(latitude: southWest.coordinate.latitude-latOffset, longitude: southWest.coordinate.longitude-lngOffset)
        northEast = CLLocation(latitude: northEast.coordinate.latitude+latOffset, longitude: northEast.coordinate.longitude+lngOffset)

        // average values
        var values: [Double] = []
        let allSensors = AIRSensor.fetch(name: name, date: date, southWest: southWest, northEast: northEast)
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            latOffset = AIRLocation.degree(meter: 50, latlng: "lat", location: location)
            lngOffset = AIRLocation.degree(meter: 50, latlng: "lng", location: location)
            minLat = location.coordinate.latitude - latOffset
            maxLat = location.coordinate.latitude + latOffset
            minLng = location.coordinate.longitude - lngOffset
            maxLng = location.coordinate.longitude + lngOffset
            let sensors = allSensors.filter( { (sensor: AIRSensor) -> Bool in
                let lat = sensor.lat.doubleValue
                let lng = sensor.lat.doubleValue
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
     * locations are healthy?
     * @param name String
     * @param date NSDate
     * @param locations [CLLocation]
     * @return [Bool]
     **/
    class func locationsAreHealthy(name name: String, date: NSDate, locations: [CLLocation]) -> [Bool] {
        // compare sensor data to WHO basement
        let averageValues = AIRSensorManager.averageSensorValues(name: name, date: date, locations: locations)
        let WHOBasements = [
            "Ozone_S": AIRSensorManager.WHOBasementOzone_S,
            "SO2": AIRSensorManager.WHOBasementSO2,
        ]

        var areHealthy: [Bool] = []

        let basement = WHOBasements[name]
        if basement == nil {
            for var i = 0; i < locations.count; i++ { areHealthy.append(true) }
        }
        for var i = 0; i < averageValues.count; i++ {
            areHealthy.append(averageValues[i] < basement)
        }
        return areHealthy
    }

    /**
     * return health evaluation
     * @param name String
     * @param date NSDate
     * @return percentage 0~100(Double)
     **/
    class func healthEvaluation(name name: String, date: NSDate) -> Double {
        let locations = AIRLocation.fetch(date: date)
        if locations.count < 2 { return 100 }

        // time interval between start location and end location
        let allInterval = locations[locations.count-1].timestamp.timeIntervalSinceDate(locations[0].timestamp)

        var centerLocations: [CLLocation] = []
        var intervals: [Double] = []

        for var i = 1; i < locations.count; i++ {
            let start = locations[i-1]
            let end = locations[i]

            // location is healthy?
            let center = CLLocation(
                latitude: (start.coordinate.latitude + end.coordinate.latitude) / 2.0,
                longitude: (start.coordinate.longitude + end.coordinate.longitude) / 2.0
            )
            centerLocations.append(center)

            // if healthy
            let interval = end.timestamp.timeIntervalSinceDate(start.timestamp) // time interval between start and end
            intervals.append(interval)
        }

        var healthValue = 0.0
        let areHealthy = AIRSensorManager.locationsAreHealthy(name: name, date: date, locations: centerLocations)
        for var i = 0; i < centerLocations.count; i++ {
            let isHealthy = areHealthy[i]
            if !isHealthy { continue }
            let interval = intervals[i]
            healthValue += Double(interval / allInterval) * 100.0
        }
        return healthValue
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
