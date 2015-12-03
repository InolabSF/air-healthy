/// MARK: - AIRSensorCircle
class AIRSensorCircle: GMSCircle {

    /// MARK: - property


    /// MARK: - initialization

    /**
     * initialization
     * @param position CLLocationCoordinate2D
     * @param color UIColor
     * @return AIRSensorCircle
     **/
    init(position: CLLocationCoordinate2D, color: UIColor) {
        super.init()

        self.position = position

        self.radius = 10.0
        self.fillColor = color
        self.strokeWidth = 30.0
        self.strokeColor = color.colorWithAlphaComponent(0.1)
    }

}
