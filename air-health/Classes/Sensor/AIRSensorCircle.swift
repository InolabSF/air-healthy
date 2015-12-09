/// MARK: - AIRSensorCircle
class AIRSensorCircle: GMSCircle {

    /// MARK: - property
    static let MaxRadius = 300.0
    static let MinRadius = 100.0


    /// MARK: - initialization

    override init() {
        super.init()
    }


    /// MARK: - class method

    /**
     * return AIRSensorCircle
     * @param sensor AIRSensor
     * @return AIRSensorCircle
     **/
    class func createSensorCircle(sensor sensor: AIRSensor) -> AIRSensorCircle? {
        let color = AIRSensorManager.sensorColor(sensor: sensor)
        if color == nil { return nil }

        let basements = AIRSensorManager.sensorBasements(name: sensor.name)
        var radius = MinRadius + (AIRSensorCircle.MaxRadius - AIRSensorCircle.MinRadius) * (basements[1] - sensor.value.doubleValue) / (basements[1] - basements[0])
        if radius > AIRSensorCircle.MaxRadius { radius = AIRSensorCircle.MaxRadius }
        if radius < AIRSensorCircle.MinRadius { radius = AIRSensorCircle.MaxRadius }

        let circle = AIRSensorCircle()
        circle.position = CLLocationCoordinate2D(latitude: sensor.lat.doubleValue, longitude: sensor.lng.doubleValue)
        circle.radius = radius
        circle.fillColor = color!.colorWithAlphaComponent(CGFloat(radius / AIRSensorCircle.MaxRadius * 0.5))
        //circle.fillColor = color
        circle.strokeWidth = 0.0
        //circle.strokeColor = color!.colorWithAlphaComponent(0.3)
        return circle
    }

}
