/// MARK: - AIRMapView
class AIRMapView: GMSMapView {

    /// MARK: - property

    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener


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
     * move camera position to my location
     **/
    func moveCameraToMyLocation() {
        let location = self.myLocation
        if location == nil { return }

        self.camera = GMSCameraPosition.cameraWithLatitude(
            location!.coordinate.latitude,
            longitude: location!.coordinate.longitude,
            zoom: 14.0
        )

    }

    /**
     * draw
     * @param pass locations you passed
     * @param color UIColor
     * @param intervalFromStart Double
     * @param sensors [AIRSensor]
     **/
    func draw(passes passes: [CLLocation], intervalFromStart: Double, color: UIColor, sensors: [AIRSensor]) {
        self.clear()

        // sensor
        self.drawSensors(sensors)
        // bad air locations
        self.drawBadAirLocations()

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
        for sensor in sensors {
            let marker = AIRSensorPolygon.marker(sensor: sensor)
            marker.map = self
        }
    }

    /**
     * draw bad air location
     **/
    private func drawBadAirLocations() {
        let locations = AIRBadAirLocation.fetch()
        for location in locations {
            let marker = AIRBadAirLocationMarker(location: location)
            marker.map = self
        }
    }

//    /**
//     * draw users
//     **/
//    private func drawUsers(users: [AIRUser]) {
//        for user in users {
//            let marker = AIRUserMarker(user: user)
//            marker.map = self
//        }
//    }

}
