/// MARK: - UIImage+AIRHeatmap
extension UIImage {

    /// MARK: - public api

    /**
     * get heatmap image
     * @map map google map
     * @map sensors [DASensor]
     * @return UIImage
     **/
    class func heatmapImage(map map: GMSMapView, sensors: [AIRSensor]) -> UIImage {
        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        for sensor in sensors {
            let lat = sensor.lat.doubleValue
            let long = sensor.lng.doubleValue
            locations.append(CLLocation(latitude: lat, longitude: long))
            weights.append(sensor.value)
        }

        var points: [NSValue] = []
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            points.append(NSValue(CGPoint: map.projection.pointForCoordinate(location.coordinate)))
        }

        let image = AIRHeatmap.crimeHeatmapWithRect(
            map.frame,
            boost: 1.0,
            points: points,
            weights: weights
        )

        return image
    }

}
