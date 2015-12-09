/// MARK: - AIRMapView
class AIRMapView: GMSMapView {

    /// MARK: - property

    /// MARK: - public api

    /**
     * move camera position
     * @param passes [CLLocation]
     **/
    func moveCamera(passes passes: [CLLocation]) {
        if passes.count < 2 { return }
        // camera
        let path = GMSMutablePath()
        for var i = 0; i < passes.count; i++ {
            let location = passes[i]
            path.addCoordinate(location.coordinate)
        }
        let bounds = GMSCoordinateBounds(path: path)
        self.moveCamera(GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)))
    }

    /**
     * draw
     * @param pass locations you passed
     * @param color UIColor
     * @param intervalFromStart Double
     * @param sensors [AIRSensor]
     **/
    func draw(passes passes: [CLLocation], intervalFromStart: Double, color color: UIColor, sensors: [AIRSensor]) {
        self.clear()

        // sensor
        self.drawSensors(sensors)

        if passes.count < 2 { return }

        let userDate = passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)
        let lineColor = UIColor.darkGrayColor()

        for var i = 1; i < passes.count; i++ {
            let start = passes[i-1]
            let end = passes[i]

            // path
            self.drawPolyline(start: start, end: end, color: lineColor)

            // user location
            if userDate.compare(start.timestamp) != .OrderedAscending && userDate.compare(end.timestamp) != .OrderedDescending {
                let ratio = userDate.timeIntervalSinceDate(start.timestamp) / end.timestamp.timeIntervalSinceDate(start.timestamp)
                let lat = (end.coordinate.latitude - start.coordinate.latitude) * ratio + start.coordinate.latitude
                let lng = (end.coordinate.longitude - start.coordinate.longitude) * ratio + start.coordinate.longitude
                let location = CLLocation(latitude: lat, longitude: lng)

                self.drawMarker(location: location, color: color)
            }

        }

    }


    /// MARK: - private api

    /**
     * draw polyline
     * @param start CLLocation
     * @param end CLLocation
     * @param color UIColor
     **/
    private func drawPolyline(start start: CLLocation, end: CLLocation, color: UIColor?) {
        let p = GMSMutablePath()
        p.addCoordinate(start.coordinate)
        p.addCoordinate(end.coordinate)
        let polyline = GMSPolyline(path: p)
        polyline.strokeWidth = 2
        if color != nil { polyline.strokeColor = color! }
        polyline.map = self
    }

    /**
     * draw marker
     * @param start CLLocation
     * @param end CLLocation
     * @param color UIColor
     **/
    private func drawMarker(location location: CLLocation, color: UIColor?) {
        let marker = GMSMarker()
        if color != nil { marker.icon = GMSMarker.markerImageWithColor(color!) }
        marker.position = location.coordinate
        marker.draggable = false
        marker.map = self
    }

    /**
     * draw sensors
     * @param sensors [AIRSensor]
     **/
    private func drawSensors(sensors: [AIRSensor]) {
        let maxDrawingCount = 100
        var locations: [CLLocation] = []
        var drawingCount = 0

        for sensor in sensors {
            let location = CLLocation(latitude: sensor.lat.doubleValue, longitude: sensor.lng.doubleValue)
            var willDraw = true
            for l in locations {
                if location.distanceFromLocation(l) < AIRSensorCircle.MaxRadius { willDraw = false; break }
            }
            if !willDraw { continue }

            if self.drawSensor(sensor) {
                drawingCount++
                locations.append(location)
            }
            if drawingCount >= maxDrawingCount { break }
        }
    }

    /**
     * draw sensor
     * @param sensor AIRSensor
     **/
    private func drawSensor(sensor: AIRSensor) -> Bool {
        let sensorCircle = AIRSensorCircle.createSensorCircle(sensor: sensor)
        if sensorCircle == nil { return false }
        sensorCircle!.map = self
        return true
    }

}
