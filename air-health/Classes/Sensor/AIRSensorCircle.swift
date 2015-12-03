/// MARK: - AIRSensorCircle
class AIRSensorCircle: GMSCircle {

    /// MARK: - property


    /// MARK: - class method

    /**
     * return AIRSensorCircle
     * @param sensor AIRSensor
     * @return AIRSensorCircle
     **/
    class func createSensorCircle(sensor sensor: AIRSensor) -> AIRSensorCircle? {
        let color = AIRSensorManager.sensorColor(sensor: sensor)
        if color == nil { return nil }

        let MinRadius = 100.0
        let MaxRadius = 200.0
        let basements = AIRSensorManager.sensorBasements(name: sensor.name)
        var radius = MinRadius + (MaxRadius - MinRadius) * (basements[1] - sensor.value.doubleValue) / (basements[1] - basements[0])
        if radius > MaxRadius { radius = MaxRadius }

        let circle = AIRSensorCircle()
        circle.position = CLLocationCoordinate2D(latitude: sensor.lat.doubleValue, longitude: sensor.lng.doubleValue)
        circle.radius = radius
        circle.fillColor = color!.colorWithAlphaComponent(0.5)
        circle.strokeWidth = 0.0
        //circle.strokeColor = color!.colorWithAlphaComponent(0.3)
        return circle
    }

}
