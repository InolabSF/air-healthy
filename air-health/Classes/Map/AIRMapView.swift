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

/*
        // path
        func drawPolyline(startIndex startIndex: Int, endIndex: Int, color: UIColor) {
            for var i = startIndex+1; i <= endIndex; i++ {
                let p = GMSMutablePath()
                let start = passes[i-1]
                let end = passes[i]
                p.addCoordinate(start.coordinate)
                p.addCoordinate(end.coordinate)
                let polyline = GMSPolyline(path: p)
                polyline.strokeColor = color
                polyline.strokeWidth = 2
                polyline.map = self
            }
        }
            // interval
        var startIndex = 0
        var endIndex = 0
        for var i = 0; i < passes.count; i++ {
            if passes[i].timestamp.compare(interval[0].timestamp) == NSComparisonResult.OrderedSame { startIndex = i; break }
        }
        for var i = 0; i < passes.count; i++ {
            if passes[i].timestamp.compare(interval[1].timestamp) == NSComparisonResult.OrderedSame { endIndex = i; break }
        }
        drawPolyline(startIndex: startIndex, endIndex: endIndex, color: UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0))
            // the others
        drawPolyline(startIndex: 0, endIndex: startIndex, color: UIColor.lightGrayColor())
        drawPolyline(startIndex: endIndex, endIndex: passes.count-1, color: UIColor.lightGrayColor())
*/
    }

}

