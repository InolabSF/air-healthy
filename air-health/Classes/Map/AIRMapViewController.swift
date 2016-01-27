/// MARK: - AIRMapViewController
class AIRMapViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var timelineView: AIRTimelineView!
    @IBOutlet weak var mapView: AIRMapView!

    var startDate: NSDate!
    var passesIndex = 0
    var passesPer6hours: [[CLLocation]] = []
    var passes: [CLLocation] {
        get {
            if passesPer6hours.count == 0 { return [] }
            return self.passesPer6hours[self.passesIndex]
        }
    }
    @IBOutlet weak var leftPassesSwitchButton: UIButton!
    @IBOutlet weak var rightPassesSwitchButton: UIButton!

    var sensors: [AIRSensor] = []
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        self.setUp()

        self.updateSensorValues()
        self.updateMapAndTimeline()

        self.drawMap()

        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("didUpdateSensorValues:"),
            name: AIRNotificationCenter.DidUpdateSensorValues,
            object: nil
        )
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
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
        else if button == self.leftPassesSwitchButton {
            self.passesIndex -= 1
            if self.passesIndex < 0 { self.passesIndex = 0 }
            self.updateMapAndTimeline()
        }
        else if button == self.rightPassesSwitchButton {
            self.passesIndex += 1
            if self.passesIndex >= self.passesPer6hours.count { self.passesIndex = self.passesPer6hours.count-1 }
            self.updateMapAndTimeline()
        }

    }


    /// MARK: - notification

    /**
     * get sensor datas
     * @param notification NSNotification
     **/
    func didUpdateSensorValues(notificatoin: NSNotification) {
        self.updateSensorValues()
        self.updateMapAndTimeline()
    }


    /// MARK: - public api

    /**
     * set passes
     * @param passes [CLLocation]
     **/
    func setPasses(p: [CLLocation]) {
        self.startDate = NSDate()
        if p.count > 0 { self.startDate = p.first!.timestamp }
        if p.count < 2 { return }

        self.passesPer6hours = []
        let last = p.last!.timestamp
        let hours = Int(last.timeIntervalSinceDate(p.first!.timestamp)) / 60 / 60
        let intervalHour = 6
        let intervalCount = 24 / intervalHour
        let separation = (hours / intervalHour >= intervalCount) ? intervalCount-1 : hours / 6
        for var i = separation; i >= 0; i-- {
            let end = last.air_hoursAgo(hours: 6*i)!
            let start = last.air_hoursAgo(hours: 6*(i+1))!
            let passesFor6hours = p.filter({ (pass: CLLocation) -> Bool in
                    return pass.timestamp.compare(start) == NSComparisonResult.OrderedDescending && end.compare(pass.timestamp) == NSComparisonResult.OrderedDescending
            })
            if passesFor6hours.count > 0 {
                self.passesPer6hours.append(passesFor6hours)
            }
        }
        self.passesIndex = self.passesPer6hours.count - 1
    }


    /// MARK: - private api

    /**
     * return current vlaue
     * @return Double
     **/
    private func currentValue() -> Double {
        let index = self.getCurrentValuesIndex(second: Double(self.timelineView.timeSlider.value))
        if index == nil { return 0.0 }
        return self.values[index!]
    }

    /**
     * return current vlaues index
     * @param second time from start
     * @return Int?
     **/
    private func getCurrentValuesIndex(second second: Double) -> Int? {
        if self.passes.count >= 2 {
            var index = -1
            let offset = self.passes.first!.timestamp.timeIntervalSinceDate(self.startDate)
            let userDate = self.passes.first!.timestamp.dateByAddingTimeInterval(second)
            for var i = 1; i < passes.count; i++ {
                let start = passes[i-1]
                let end = passes[i]
                if userDate.compare(start.timestamp) != .OrderedAscending && userDate.compare(end.timestamp) != .OrderedDescending {
                    index = Int(second+offset) / 60
                }
            }
            if index >= 0 && index < self.values.count { return index }
        }
        return nil
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

        // left passes switch button
        self.leftPassesSwitchButton.setImage(
            IonIcons.imageWithIcon(
                ion_ios_arrow_back,
                iconColor: UIColor.grayColor(),
                iconSize: 32,
                imageSize: CGSizeMake(32, 32)),
            forState: .Normal
        )
        // right passes switch button
        self.rightPassesSwitchButton.setImage(
            IonIcons.imageWithIcon(
                ion_ios_arrow_forward,
                iconColor: UIColor.grayColor(),
                iconSize: 32,
                imageSize: CGSizeMake(32, 32)),
            forState: .Normal
        )

        // timelineView
        self.timelineView.timeSliderTitleLabel.text = self.chemical

        // mapview
        self.mapView.myLocationEnabled = true
        self.mapView.settings.myLocationButton = false
        self.mapView.frame = CGRectMake(
            self.mapView.frame.origin.x, self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height,
            self.mapView.frame.width, self.view.frame.height - (self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height + self.timelineView.timeSliderView.frame.height) + 36.0
        )
        self.mapView.camera = GMSCameraPosition.cameraWithLatitude(
            37.7833,
            longitude: -122.4167,
            zoom: 13.0
        )
    }

    /**
     * update sensor values
     **/
    private func updateSensorValues() {
        self.SO2ValuePerMinutes = AIRSummary.sharedInstance.SO2ValuePerMinutes
        self.O3ValuePerMinutes = AIRSummary.sharedInstance.O3ValuePerMinutes
        var name = ""
        if self.chemical == "SO2" { name = "SO2" }
        else if self.chemical == "O3" { name = "Ozone_S" }
        self.setPasses(AIRSummary.sharedInstance.passes)
        self.sensors = AIRSummary.sharedInstance.sensors.filter({ (sensor: AIRSensor) -> Bool in
            return sensor.name == name
        })
    }

    /**
     * update map and timeline
     **/
    private func updateMapAndTimeline() {
        self.setSensorValues()
        self.designPassesSwitchButtons()
        if self.passes.count < 2 { self.mapView.moveCameraToMyLocation() }
        else { self.mapView.moveCamera(passes: self.passes) }
        self.drawMap()
    }

    /**
     * draw map
     **/
    private func drawMap() {
        var color = UIColor.clearColor()
        if self.passes.count >= 2 { color = AIRSensorManager.sensorColor(value: self.currentValue(), sensorBasements: self.basements) }
        self.mapView.draw(
            passes: self.passes,
            intervalFromStart: Double(self.timelineView.timeSlider.value),
            color: color,
            sensors: self.sensors
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
        if self.passes.count >= 2 {
            let allInterval = self.passes.last!.timestamp.timeIntervalSinceDate(self.passes.first!.timestamp)
            self.timelineView.timeSlider.maximumValue = CGFloat(allInterval)
            let date = self.passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)
            let dateFormatter = NSDateFormatter.air_dateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            time = dateFormatter.stringFromDate(date)

            color = AIRSensorManager.sensorColor(value: self.currentValue(), sensorBasements: self.basements)

            self.timelineView.setDate(date)
        }
        else {
            self.timelineView.setDate(NSDate())
        }

        self.timelineView.setTimeline(time: time, color: color)
    }

    /**
     * set sensor datas
     **/
    private func setSensorValues() {
        var allInterval = 0.0

        // timeline
        if self.passes.count >= 2 {
            allInterval = self.passes.last!.timestamp.timeIntervalSinceDate(self.passes.first!.timestamp)
            self.timelineView.timeSlider.maximumValue = CGFloat(allInterval)
            if self.timelineView.timeSlider.maximumValue > 0.0 { self.timelineView.timeSlider.value = self.timelineView.timeSlider.maximumValue }
        }

        let startIndex = self.getCurrentValuesIndex(second: 0.0)
        let endIndex = self.getCurrentValuesIndex(second: allInterval)
        if startIndex == nil || endIndex == nil { return }

        // timeline
        self.timelineView.setLineChart(
            passes: self.passes,
            valuesPerMinute: self.values.slice((startIndex!), (endIndex!)),
            sensorBasements: self.basements
        )
        self.setTimeline()
    }

    /**
     * design passes switch button
     **/
    private func designPassesSwitchButtons() {
        self.leftPassesSwitchButton.hidden = false
        self.rightPassesSwitchButton.hidden = false

        if self.passesIndex == 0 {
            self.leftPassesSwitchButton.hidden = true
        }
        if self.passesIndex == self.passesPer6hours.count-1 {
            self.rightPassesSwitchButton.hidden = true
        }
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
        self.drawMap() // draw map
    }

    func mapView(mapView: GMSMapView,  didDragMarker marker:GMSMarker) {
    }

}


/// MARK: - AIRTimelineViewDelegate
extension AIRMapViewController: AIRTimelineViewDelegate {

    func valueChanged(timelineView timelineView: AIRTimelineView, control: GradientSlider) {
        self.drawMap() // draw map
        self.setTimeline() // timeline
    }

}
