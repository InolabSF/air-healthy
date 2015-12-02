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
     * @param sensorBasements [Double]
     **/
    func draw(passes passes: [CLLocation], intervalFromStart: Double, averageSensorValues: [Double], sensorBasements: [Double]) {
        self.clear()
        if passes.count == 0 { return }

        let date = passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)
        var markerColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)

        for var i = 1; i < passes.count; i++ {
            let start = passes[i-1]
            let end = passes[i]

            // draw passes' line
            let p = GMSMutablePath()
            p.addCoordinate(start.coordinate)
            p.addCoordinate(end.coordinate)
            let polyline = GMSPolyline(path: p)
            polyline.strokeWidth = 4
            let value = (averageSensorValues[i-1] + averageSensorValues[i]) / 2.0
            if value < sensorBasements[0] {
                polyline.strokeColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            }
            else if value < sensorBasements[1] {
                polyline.strokeColor = UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
            }
            else {
                polyline.strokeColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
            }
            polyline.map = self

            // marker
            if date.compare(start.timestamp) != .OrderedAscending && date.compare(end.timestamp) != .OrderedDescending {
                markerColor = polyline.strokeColor
                let ratio = date.timeIntervalSinceDate(start.timestamp) / end.timestamp.timeIntervalSinceDate(start.timestamp)
                let lat = (end.coordinate.latitude - start.coordinate.latitude) * ratio + start.coordinate.latitude
                let lng = (end.coordinate.longitude - start.coordinate.longitude) * ratio + start.coordinate.longitude
                let stop = CLLocation(latitude: lat, longitude: lng)

                let marker = GMSMarker()
                marker.icon = GMSMarker.markerImageWithColor(markerColor)
                marker.position = stop.coordinate
                marker.draggable = false
                marker.map = self
            }
        }
    }

}

