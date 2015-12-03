/// MARK: - AIRMapView
class AIRMapView: GMSMapView {

    /// MARK: - property


    /// MARK: - public api

    /**
     * move camera position
     * @param passes [CLLocation]
     **/
    func moveCamera(passes passes: [CLLocation]) {
        if passes.count == 0 { return }
        // camera
        let path = GMSMutablePath()
        for var i = 0; i < passes.count; i++ {
            let location = passes[i]
            path.addCoordinate(location.coordinate)
        }
        let bounds = GMSCoordinateBounds(path: path)
        //self.moveCamera(GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsetsMake(140.0, 40.0, 120.0, 80.0)))
        self.moveCamera(GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)))
    }

    /**
     * draw
     * @param pass locations you passed
     * @param intervalFromStart Double
     * @param averageSensorValues [Double]
//     * @param sensors [AIRSensor]
     * @param sensorBasements [Double]
     **/
    func draw(passes passes: [CLLocation], intervalFromStart: Double, averageSensorValues: [Double], /*sensors: [AIRSensor], */sensorBasements: [Double]) {
        self.clear()

//        // sensor
//        for sensor in sensors {
//            let sensorCircle = AIRSensorCircle(
//                position: CLLocationCoordinate2D(latitude: sensor.lat.doubleValue, longitude: sensor.lng.doubleValue),
//                color: AIRSensorManager.sensorColor(value: sensor.value.doubleValue, sensorBasements: sensorBasements)
//            )
//            sensorCircle.map = self
//        }

        if passes.count == 0 { return }

        let date = passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)

        for var i = 1; i < passes.count; i++ {
            let start = passes[i-1]
            let end = passes[i]
            let value = (averageSensorValues[i-1] + averageSensorValues[i]) / 2.0
            let color = AIRSensorManager.sensorColor(value: value, sensorBasements: sensorBasements)

            // polyline
            self.drawPolyline(start: start, end: end, color: color)

            // marker
            if date.compare(start.timestamp) != .OrderedAscending && date.compare(end.timestamp) != .OrderedDescending {
                let ratio = date.timeIntervalSinceDate(start.timestamp) / end.timestamp.timeIntervalSinceDate(start.timestamp)
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
    private func drawPolyline(start start: CLLocation, end: CLLocation, color: UIColor) {
        let p = GMSMutablePath()
        p.addCoordinate(start.coordinate)
        p.addCoordinate(end.coordinate)
        let polyline = GMSPolyline(path: p)
        polyline.strokeWidth = 4
        polyline.strokeColor = color
        polyline.map = self
    }

    /**
     * draw marker
     * @param start CLLocation
     * @param end CLLocation
     * @param color UIColor
     **/
    private func drawMarker(location location: CLLocation, color: UIColor) {
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImageWithColor(color)
        marker.position = location.coordinate
        marker.draggable = false
        marker.map = self
    }


/*
        // tile
        if self.tileLayer != nil { self.tileLayer!.map = nil }
        if mode == HMAUserInterface.Mode.SetRoute {
            self.mapType = kGMSTypeNone
            if self.tileLayer == nil {
                let urls : GMSTileURLConstructor = { x, y, zoom in
                    return NSURL(string: "\(HMAMapbox.API.Tiles)\(HMAMapbox.MapID)/\(zoom)/\(x)/\(y).png?access_token=\(HMAMapbox.AccessToken)")
                }
                self.tileLayer = GMSURLTileLayer(URLConstructor: urls)
                self.tileLayer!.zIndex = HMAGoogleMap.ZIndex.Tile
            }
            self.tileLayer!.map = self
        }
        else {
            self.mapType = kGMSTypeNormal
        }
*/
}
