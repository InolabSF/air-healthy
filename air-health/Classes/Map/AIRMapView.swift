/// MARK: - AIRMapView
class AIRMapView: GMSMapView {

    /// MARK: - property

    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setMinZoom(AIRGoogleMap.Zoom.Min, maxZoom: AIRGoogleMap.Zoom.Max)
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

        if self.camera.zoom > AIRGoogleMap.Zoom.Max {
            self.moveCamera(GMSCameraUpdate.zoomBy(AIRGoogleMap.Zoom.Max, atPoint: self.center))
        }
        else if self.camera.zoom < AIRGoogleMap.Zoom.Min {
            self.moveCamera(GMSCameraUpdate.zoomBy(AIRGoogleMap.Zoom.Min, atPoint: self.center))
        }
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
            zoom: AIRGoogleMap.Zoom.Default
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
        let offsetX = self.frame.width * 0.25
        let offsetY = self.frame.height * 0.25
        let points = [CGPointMake(-offsetX, -offsetY), CGPointMake(self.frame.width+offsetX, -offsetY), CGPointMake(-offsetX, self.frame.height+offsetY), CGPointMake(self.frame.width+offsetX, self.frame.height+offsetY),]
        var min = self.minimumCoordinate(mapViewPoints: points)
        var max = self.maximumCoordinate(mapViewPoints: points)
        min = CLLocationCoordinate2DMake(min.latitude-0.01, min.longitude-0.01)
        max = CLLocationCoordinate2DMake(max.latitude+0.01, max.longitude+0.01)

        for sensor in sensors {
            let lat = sensor.lat.doubleValue
            let lng = sensor.lng.doubleValue
            if lat < min.latitude || lat > max.latitude || lng < min.longitude || lng > max.longitude { continue }

            let marker = AIRSensorPolygon.marker(sensor: sensor, radius: 0.0010)
            marker.map = self
        }
    }

}


/// MARK: -
extension AIRMapView {

    /**
     * get minimumCoordinate
     * @param mapViewPoints coordinates on GMSMapView
     * @return CLLocationCoordinate2D
     **/
    func minimumCoordinate(mapViewPoints mapViewPoints: [CGPoint]) -> CLLocationCoordinate2D {
        var min = self.projection.coordinateForPoint(mapViewPoints[0])
        for point in mapViewPoints {
            let coordinate = self.projection.coordinateForPoint(point)
            if min.latitude > coordinate.latitude { min.latitude = coordinate.latitude }
            if min.longitude > coordinate.longitude { min.longitude = coordinate.longitude }
        }
        return min
    }

    /**
     * get maximumCoordinate
     * @param mapViewPoints coordinates on GMSMapView
     * @return CLLocationCoordinate2D
     **/
    func maximumCoordinate(mapViewPoints mapViewPoints: [CGPoint]) -> CLLocationCoordinate2D {
        var max = self.projection.coordinateForPoint(mapViewPoints[0])
        for point in mapViewPoints {
            let coordinate = self.projection.coordinateForPoint(point)
            if max.latitude < coordinate.latitude { max.latitude = coordinate.latitude }
            if max.longitude < coordinate.longitude { max.longitude = coordinate.longitude }
        }
        return max
    }

}
