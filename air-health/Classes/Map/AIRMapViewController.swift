/// MARK: - AIRMapViewController
class AIRMapViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var timelineView: AIRTimelineView!
    @IBOutlet weak var mapView: AIRMapView!

    var passes: [CLLocation] = []
    //var values: [Double] = []
    var sensors: [AIRSensor] = []
    //var users: [AIRUser] = []
    var chemical = ""

    var SO2ValuePerMinutes: [Double] = []
    var O3ValuePerMinutes: [Double] = []

    var values: [Double] {
        get {
            if self.chemical == "SO2" { return self.SO2ValuePerMinutes }
            if self.chemical == "O3" { return self.O3ValuePerMinutes }
            return []
        }
    }

    var basements: [Double] {
        get {
            var name = ""
            if self.chemical == "SO2" { name = "SO2" }
            if self.chemical == "O3" { name = "Ozone_S" }
            return AIRSensorManager.sensorBasements(name: name)
        }
    }


    /// MARK: - destruction

    deinit {
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        self.setUp()

        var name = ""
        if self.chemical == "SO2" { name = "SO2" }
        else if self.chemical == "O3" { name = "Ozone_S" }
        self.sensors = self.sensors.filter( { (sensor: AIRSensor) -> Bool in
            return sensor.name == name
        })
        self.setSensorValues()

        self.mapView.moveCamera(passes: self.passes)
        self.drawMap()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // status bar
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
        if button == self.leftBarButton {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }


    /// MARK: - notification


    /// MARK: - private api

    /**
     * return current vlaue
     * @return Double
     **/
    func currentValue() -> Double {
        if self.passes.count >= 2 {
            let control = self.timelineView.timeSlider
            var index = -1
            let userDate = self.passes.first!.timestamp.dateByAddingTimeInterval(Double(control.value))
            for var i = 1; i < passes.count; i++ {
                let start = passes[i-1]
                let end = passes[i]
                if userDate.compare(start.timestamp) != .OrderedAscending && userDate.compare(end.timestamp) != .OrderedDescending {
                    index = Int(control.value / 60)
                }
            }
            if index >= 0 && index < self.values.count {
                return self.values[index]
            }
        }
        return 0.0
    }

    /**
     * set up
     **/
    private func setUp() {
        // status bar
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        // navigation bar
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 16.0/255.0, green: 16.0/255.0, blue: 16.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]

        // left bar button
        self.leftBarButton.setImage(
            IonIcons.imageWithIcon(
                ion_ios_arrow_back,
                iconColor: UIColor.whiteColor(),
                iconSize: 22,
                imageSize: CGSizeMake(22, 22)),
            forState: .Normal
        )
        // right bar button
        self.rightBarButton.setImage(
            IonIcons.imageWithIcon(
                ion_android_settings,
                iconColor: UIColor.whiteColor(),
                iconSize: 22,
                imageSize: CGSizeMake(22, 22)),
            forState: .Normal
        )

        // timelineView
        self.timelineView.timeSliderTitleLabel.text = self.chemical

        // mapview
        self.mapView.myLocationEnabled = true
        self.mapView.settings.myLocationButton = false
        //self.mapView.trafficEnabled = true
        self.mapView.frame = CGRectMake(
            self.mapView.frame.origin.x, self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height,
            self.mapView.frame.width, self.view.frame.height - (self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height + self.timelineView.timeSliderView.frame.height) + 36.0
        )
        self.mapView.camera = GMSCameraPosition.cameraWithLatitude(
            37.7833,
            longitude: -122.4167,
            zoom: 13.0
        )
        //self.mapView.air_delegate = self
    }

    /**
     * draw map
     **/
    private func drawMap() {
        var color = UIColor.clearColor()
        if self.passes.count > 0 { color = AIRSensorManager.sensorColor(value: self.currentValue(), sensorBasements: self.basements) }
        self.mapView.draw(
            passes: self.passes,
            intervalFromStart: Double(self.timelineView.timeSlider.value),
            color: color,
            sensors: self.sensors
            //users: self.users
        )
    }

    /**
     * set timeline
     * @param sensorGraphButton AIRSensorGraphView's button
     **/
    private func setTimeline() {
        let intervalFromStart = Double(self.timelineView.timeSlider.value)

        // time
        var time = ""
        var color = UIColor.clearColor()
        if self.passes.count > 0 {
            let allInterval = self.passes.last!.timestamp.timeIntervalSinceDate(self.passes.first!.timestamp)
            self.timelineView.timeSlider.maximumValue = CGFloat(allInterval)
            let date = self.passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            time = dateFormatter.stringFromDate(date)

            color = AIRSensorManager.sensorColor(value: self.currentValue(), sensorBasements: self.basements)
        }

        self.timelineView.setTimeline(time: time, color: color)
    }

    /**
     * set sensor datas
     **/
    private func setSensorValues() {
        // timeline
        if self.passes.count > 0 {
            let allInterval = self.passes.last!.timestamp.timeIntervalSinceDate(self.passes.first!.timestamp)
            self.timelineView.timeSlider.maximumValue = CGFloat(allInterval)
            if self.timelineView.timeSlider.maximumValue > 0.0 { self.timelineView.timeSlider.value = self.timelineView.timeSlider.maximumValue }
        }

        // timeline
        self.timelineView.setLineChart(
            passes: self.passes,
            valuesPerMinute: self.values,
            sensorBasements: self.basements
        )
        self.setTimeline()
    }
}


/// MARK: - GMSMapViewDelegate
extension AIRMapViewController: GMSMapViewDelegate {

    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    }

    func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if marker.isKindOfClass(AIRBadAirLocationMarker) {
            (marker as! AIRBadAirLocationMarker).shareSocial(parentViewController: self)
        }

        self.mapView.selectedMarker = marker

        return true
    }

    func mapView(mapView: GMSMapView,  didBeginDraggingMarker marker: GMSMarker) {
    }

    func mapView(mapView: GMSMapView,  didEndDraggingMarker marker: GMSMarker) {
    }

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
    }

    func mapView(mapView: GMSMapView,  didDragMarker marker:GMSMarker) {
    }

}


//// MARK: - AIRMapViewDelegate
//extension AIRMapViewController: AIRMapViewDelegate {
//
//    func touchedUpInside(mapView mapView: AIRMapView, button: UIButton) {
//        self.drawMap()
//    }
//
//}


/// MARK: - AIRTimelineViewDelegate
extension AIRMapViewController: AIRTimelineViewDelegate {
/*
    func touchedUpInside(timelineView timelineView: AIRTimelineView, openButton: UIButton) {
        self.drawMap()
        self.mapView.moveCamera(passes: self.passes)
        // get users
        let location = self.mapView.myLocation
        if location != nil {
            AIRUserClient.sharedInstance.getUser(location: location!, radius: 5.0, completionHandler: { [unowned self] (json) in
                    self.users = AIRUser.users(json: json)
                    self.drawMap()
                }
            )
        }
        self.sensorGraphView.toggle(
            hidden: true,
            animationHandler: { () in },
            completionHandler:{ () in }
        )
    }
*/

/*
    func touchedUpInside(timelineView timelineView: AIRTimelineView, closeButton: UIButton) {
        self.sensorGraphView.toggle(
            hidden: false,
            animationHandler: { () in },
            completionHandler:{ () in }
        )
    }
*/

    func valueChanged(timelineView timelineView: AIRTimelineView, control: GradientSlider) {
        self.drawMap() // draw map
        self.setTimeline() // timeline
    }

}
