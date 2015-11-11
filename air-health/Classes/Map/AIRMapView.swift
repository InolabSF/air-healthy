/// MARK: - AIRMapView
class AIRMapView: GMSMapView {

    /// MARK: - property


    /// MARK: - public api

    /**
     * draw
     * @param locations locations that you passed
     **/
    func draw(locations locations: [CLLocation]) {
        self.clear()

        // camera
        let path = GMSMutablePath()
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            path.addCoordinate(location.coordinate)
        }
        let bounds = GMSCoordinateBounds(path: path)
        self.moveCamera(GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsetsMake(140.0, 40.0, 120.0, 80.0)))

        // marker
        for var i = 0; i < locations.count; i++ {
            let marker = GMSMarker()
            marker.position = locations[i].coordinate
            marker.draggable = false
            marker.map = self
        }

        // path
        for var i = 1; i < locations.count; i++ {
            let p = GMSMutablePath()
            let start = locations[i-1]
            let end = locations[i]
            p.addCoordinate(start.coordinate)
            p.addCoordinate(end.coordinate)
            let polyline = GMSPolyline(path: p)
            polyline.map = self
        }
    }
}

