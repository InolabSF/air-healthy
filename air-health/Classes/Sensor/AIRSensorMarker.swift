/// MARK: - AIRSensorPolygon
class AIRSensorPolygon: GMSPolygon {

    /// MARK: - property

    static let Radius = 100.0


    /// MARK: - initialization


    /// MARK: - class method

    /**
     * return AIRSensorPolygon
     * @param sensor AIRSensor
     * @return AIRSensorPolygon
     **/
    class func marker(sensor sensor: AIRSensor) -> AIRSensorPolygon {
        let center = CLLocation(latitude: sensor.lat.doubleValue, longitude: sensor.lng.doubleValue)
        let latOffset = 0.00125//AIRLocation.degree(meter: AIRSensorPolygon.Radius, latlng: "lat", location: center)
        let lngOffset = 0.00125//AIRLocation.degree(meter: AIRSensorPolygon.Radius, latlng: "lng", location: center)
        let lat = center.coordinate.latitude
        let lng = center.coordinate.longitude

        let rect = GMSMutablePath()
        rect.addCoordinate(CLLocationCoordinate2DMake(lat-latOffset, lng-lngOffset))
        rect.addCoordinate(CLLocationCoordinate2DMake(lat+latOffset, lng-lngOffset))
        rect.addCoordinate(CLLocationCoordinate2DMake(lat+latOffset, lng+lngOffset))
        rect.addCoordinate(CLLocationCoordinate2DMake(lat-latOffset, lng+lngOffset))

        let marker = AIRSensorPolygon(path: rect)
        marker.fillColor = AIRSensorManager.sensorColor(sensor: sensor).colorWithAlphaComponent(CGFloat(0.35))
        marker.strokeWidth = 0.0
        return marker
    }

}


// MARK: - AIRSensorCircle
class AIRSensorCircle: GMSCircle {


    /// MARK: - property

    static let MaxRadius = 300.0
    static let MinRadius = 100.0


    /// MARK: - class method

    /**
     * return AIRSensorCircle
     * @param sensor AIRSensor
     * @return AIRSensorCircle
     **/
    class func marker(sensor sensor: AIRSensor) -> AIRSensorCircle? {
        let color = AIRSensorManager.sensorCircleColor(sensor: sensor)
        if color == nil { return nil }
        let basements = AIRSensorManager.sensorBasements(chemical: sensor.name)
        var radius = MinRadius + (AIRSensorCircle.MaxRadius - AIRSensorCircle.MinRadius) * (basements[1] - sensor.value.doubleValue) / (basements[1] - basements[0])
        if radius > AIRSensorCircle.MaxRadius { radius = AIRSensorCircle.MaxRadius }
        if radius < AIRSensorCircle.MinRadius { radius = AIRSensorCircle.MaxRadius }

        let circle = AIRSensorCircle()
        circle.position = CLLocationCoordinate2D(latitude: sensor.lat.doubleValue, longitude: sensor.lng.doubleValue)
        circle.radius = radius
        circle.fillColor = color!.colorWithAlphaComponent(CGFloat(radius / AIRSensorCircle.MaxRadius * 0.5))
        circle.strokeWidth = 0.0
        return circle
    }
}
