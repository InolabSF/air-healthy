/// MARK: - AIRMapView
class AIRMapView: GMSMapView {

    /// MARK: - property


    /// MARK: - public api

    /**
     * draw
     * @param passes locations that you passed
     * @param stops locations that you stopped
     **/
    func draw(passes passes: [CLLocation], stops: [CLLocation]) {
        self.clear()

        // camera
        let path = GMSMutablePath()
        for var i = 0; i < passes.count; i++ {
            let location = passes[i]
            path.addCoordinate(location.coordinate)
        }
        let bounds = GMSCoordinateBounds(path: path)
        self.moveCamera(GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsetsMake(140.0, 40.0, 120.0, 80.0)))

        // marker
        for var i = 0; i < stops.count; i++ {
            let marker = GMSMarker()
            marker.position = stops[i].coordinate
            marker.draggable = false
            marker.map = self
        }

        // path
        for var i = 1; i < passes.count; i++ {
            let p = GMSMutablePath()
            let start = passes[i-1]
            let end = passes[i]
            p.addCoordinate(start.coordinate)
            p.addCoordinate(end.coordinate)
            let polyline = GMSPolyline(path: p)
            polyline.strokeWidth = 2
            polyline.map = self
        }
    }

}

