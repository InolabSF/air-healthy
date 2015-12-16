// MARK: - AIRMapViewDelegate
@objc protocol AIRMapViewDelegate {

    /**
     * called when button is touched up inside
     * @param mapView AIRMapView
     * @param openButton UIButton
     */
    func touchedUpInside(mapView mapView: AIRMapView, button: UIButton)

}


/// MARK: - AIRMapView
class AIRMapView: GMSMapView {

    /// MARK: - property

    @IBOutlet weak var air_delegate: AnyObject?

    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var rectButton: UIButton!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.bringSubviewToFront(self.circleButton)
        self.bringSubviewToFront(self.rectButton)
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(button button: UIButton) {
        self.rectButton.hidden = true
        self.circleButton.hidden = true

        if button == self.circleButton {
            self.rectButton.hidden = false
        }
        else if button == self.rectButton {
            self.circleButton.hidden = false
        }

        if self.delegate != nil {
            (self.air_delegate as! AIRMapViewDelegate).touchedUpInside(mapView: self, button: button)
        }
    }


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

        if !self.circleButton.hidden {

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

            let marker = AIRSensorCircle.marker(sensor: sensor)
            if marker != nil {
                marker!.map = self
                drawingCount++
                locations.append(location)
            }
            if drawingCount >= maxDrawingCount { break }
        }

        }

        if !self.rectButton.hidden {

        for sensor in sensors {
            let marker = AIRSensorPolygon.marker(sensor: sensor)
            marker.map = self
        }

        }

/*
        let overlay = GMSGroundOverlay(
            position: self.projection.coordinateForPoint(CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)),
            icon: UIImage.heatmapImage(map: self, sensors: sensors),
            zoomLevel: CGFloat(self.camera.zoom)
        )
        overlay.bearing = self.camera.bearing
        overlay.map = self
*/
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

}
