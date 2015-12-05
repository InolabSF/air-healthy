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
     * @param intervalFromStart Double
     * @param sensors [AIRSensor]
     **/
    func draw(passes passes: [CLLocation], intervalFromStart: Double, sensors: [AIRSensor]) {
        self.clear()

        // sensor
        self.drawSensors(sensors)

        if passes.count < 2 { return }

        let userDate = passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)
        let color = UIColor.darkGrayColor()

        for var i = 1; i < passes.count; i++ {
            let start = passes[i-1]
            let end = passes[i]

            // path
            self.drawPolyline(start: start, end: end, color: color)

            // user location
            if userDate.compare(start.timestamp) != .OrderedAscending && userDate.compare(end.timestamp) != .OrderedDescending {
                let ratio = userDate.timeIntervalSinceDate(start.timestamp) / end.timestamp.timeIntervalSinceDate(start.timestamp)
                let lat = (end.coordinate.latitude - start.coordinate.latitude) * ratio + start.coordinate.latitude
                let lng = (end.coordinate.longitude - start.coordinate.longitude) * ratio + start.coordinate.longitude
                let location = CLLocation(latitude: lat, longitude: lng)
                self.drawMarker(location: location, color: nil)
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
/*
        let distance = 200.0
        var drawnSensors: [AIRSensor] = []
        var nextIndex = 1
        for var i = 0; i < sensors.count; i = nextIndex {
            var sensor = sensors[i]
            let locationI = CLLocation(latitude: sensors[i].lat.doubleValue, longitude: sensors[i].lng.doubleValue)

            for var j = i+1; j < sensors.count; j++ {
                let locationJ = CLLocation(latitude: sensors[j].lat.doubleValue, longitude: sensors[j].lng.doubleValue)
                if locationI.distanceFromLocation(locationJ) > distance { nextIndex = j; break }
                if sensors[j].value.doubleValue < sensors[i].value.doubleValue { sensor = sensors[j] }
                if j == sensors.count - 1 { nextIndex = sensors.count; break }
            }

            drawnSensors.append(sensor)
        }
        for sensor in drawnSensors { self.drawSensor(sensor) }
*/
        for sensor in sensors { self.drawSensor(sensor) }
    }

    /**
     * draw sensor
     * @param sensor AIRSensor
     **/
    private func drawSensor(sensor: AIRSensor) {
        let sensorCircle = AIRSensorCircle.createSensorCircle(sensor: sensor)
        if sensorCircle == nil { return }
        sensorCircle!.map = self
    }

}
