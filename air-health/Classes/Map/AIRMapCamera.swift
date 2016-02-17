/// MARK: - AIRMapCamera
class AIRMapCamera: NSObject {

    static let sharedInstance = AIRMapCamera()


    /// MARK: - property

    var center: CLLocation? = nil
    var zoom: Float? = nil


    /// MARK: - initialization
    override init() {
        super.init()
    }

    /// MARK: - destruction

    deinit {
    }


    /// MARK: - public api

    /**
     * has current camera?
     * @return Bool
     **/
    func hasCurrentCamera() -> Bool {
        return (self.center != nil && self.zoom != nil)
    }

    /**
     * current camera
     * @return GMSCameraPosition
     **/
    func currentCamera() -> GMSCameraPosition {
        return GMSCameraPosition.cameraWithLatitude(
            self.center!.coordinate.latitude,
            longitude: self.center!.coordinate.longitude,
            zoom: self.zoom!
        )
    }

    /**
     * set camera
     * @param center CLLocation
     * @param zoom Float
     **/
    func set(center center: CLLocation, zoom: Float) {
        self.center = center
        self.zoom = zoom
    }

    /**
     * reset
     **/
    func reset() {
        self.center = nil
        self.zoom = nil
    }

}
