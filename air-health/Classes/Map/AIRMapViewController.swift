/// MARK: - AIRMapViewController
class AIRMapViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var timelineView: AIRTimelineView!
    @IBOutlet weak var mapView: AIRMapView!

    //var cameraBounds: GMSCoordinateBounds? = nil

    var moveStartDate: NSDate!
    var moveEndDate: NSDate!
    var passesIndex = 0
    var passesPer6hours: [[CLLocation]] = []
    var passes: [CLLocation] {
        get {
            if self.passesPer6hours.count == 0 { return [] }
            return self.passesPer6hours[self.passesIndex]
        }
    }
    @IBOutlet weak var leftPassesSwitchButton: UIButton!
    @IBOutlet weak var rightPassesSwitchButton: UIButton!

    var sensors: [AIRSensor] = []
    var chemical = ""

    var NO2ValuePerMinutes: [Double] = []
    var PM25ValuePerMinutes: [Double] = []
    var UVValuePerMinutes: [Double] = []
    var COValuePerMinutes: [Double] = []
    var SO2ValuePerMinutes: [Double] = []
    var O3ValuePerMinutes: [Double] = []

    var values: [Double] {
        get {
            let name = AIRSensorManager.sensorName(chemical: self.chemical)
            if name == "NO2" { return self.NO2ValuePerMinutes }
            if name == "PM25" { return self.PM25ValuePerMinutes }
            if name == "UV" { return self.UVValuePerMinutes }
            if name == "CO" { return self.COValuePerMinutes }
            if name == "SO2" { return self.SO2ValuePerMinutes }
            if name == "O3" { return self.O3ValuePerMinutes }
            return []
        }
    }

    var basements: [Double] {
        get {
            return AIRSensorManager.sensorBasements(chemical: self.chemical)
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

        self.timelineView.setDate(self.moveEndDate)

        self.drawMap()

        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("didUpdateSensorValues:"),
            name: AIRNotificationCenter.DidUpdateSensorValues,
            object: nil
        )
        //NSNotificationCenter.defaultCenter().addObserver(
        //    self,
        //    selector: Selector("didUpdateMapSensors:"),
        //    name: AIRNotificationCenter.DidUpdateMapSensors,
        //    object: nil
        //)
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

        AIRMapCamera.sharedInstance.set(center: CLLocation(latitude: self.mapView.camera.target.latitude, longitude: self.mapView.camera.target.longitude), zoom: self.mapView.camera.zoom)

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
            AIRMapCamera.sharedInstance.reset()

            self.passesIndex -= 1
            if self.passesIndex < 0 { self.passesIndex = 0 }
            self.updateMapAndTimeline()
        }
        else if button == self.rightPassesSwitchButton {
            AIRMapCamera.sharedInstance.reset()

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

    ///**
    // * called when updated sensors on map
    // * @param notification NSNotification
    // **/
    //func didUpdateMapSensors(notificatoin: NSNotification) {
    //    dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
    //        self.sensors = notificatoin.object as! [AIRSensor]
    //        self.updateMapAndTimeline()
    //    })
    //}


    /// MARK: - public api

    /**
     * set passes
     * @param passes [CLLocation]
     **/
    func setPasses(locations: [CLLocation]) {
        self.passesPer6hours = []
        let now = NSDate()
        self.moveStartDate = now
        self.moveEndDate = now

        if locations.count == 0 { return }

        self.moveStartDate = locations.first!.timestamp
        let last = locations.last!.timestamp.air_minutesAgo(minutes: 1)!
        self.moveEndDate = last
        let intervalHour = Int(AIRTimelineView.Hour)

        //let separation = Int(24.0 / AIRTimelineView.Hour)
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour], fromDate: last)
        let separation = (comp.hour / intervalHour) + 1

        for var i = 0; i < separation; i++ {
            var end = last.air_hoursAgo(hours: intervalHour*i)!
            if end.compare(now) == NSComparisonResult.OrderedDescending { end = now }
            let start = last.air_hoursAgo(hours: intervalHour*(i+1))!
            var passesFor6hours = locations.filter({ (pass: CLLocation) -> Bool in
                return (pass.timestamp.compare(start) == NSComparisonResult.OrderedDescending && end.compare(pass.timestamp) == NSComparisonResult.OrderedDescending)
            })

            if passesFor6hours.count > 0 {
                let first = AIRLocation.location(passesFor6hours.first!, timestamp: start)
                let last = AIRLocation.location(passesFor6hours.last!, timestamp: end)
                if passesFor6hours.count == 1 { passesFor6hours = [first, last] }
                else { passesFor6hours[0] = first; passesFor6hours[passesFor6hours.count-1] = last }
            }
            self.passesPer6hours.append(passesFor6hours)
        }
        for var i = 0; i < self.passesPer6hours.count; i++ {
            if self.passesPer6hours[i].count > 0 { continue }

            let end = last.air_hoursAgo(hours: intervalHour*i)!
            let start = last.air_hoursAgo(hours: intervalHour*(i+1))!

            var j = 1
            while self.passesPer6hours[i].count == 0 {
                var index = i+j
                if index < self.passesPer6hours.count && self.passesPer6hours[index].count > 0 {
                    self.passesPer6hours[i] = [AIRLocation.location(self.passesPer6hours[index].last!, timestamp: start), AIRLocation.location(self.passesPer6hours[index].last!, timestamp: end)]
                    break
                }
                index = i-j
                if index >= 0 && self.passesPer6hours[index].count > 0 {
                    self.passesPer6hours[i] = [AIRLocation.location(self.passesPer6hours[index].first!, timestamp: start), AIRLocation.location(self.passesPer6hours[index].first!, timestamp: end)]
                    break
                }

                j++
            }
        }
        self.passesPer6hours = self.passesPer6hours.reverse()
        self.passesIndex = self.passesPer6hours.count - 1



        var passesCount = 0
        for p in self.passesPer6hours {
            passesCount += p.count
        }
        if passesCount == 0 { self.passesPer6hours = [] }
    }

    /// MARK: - private api

    /**
     * return current vlaue
     * @return Double
     **/
    private func currentValue() -> Double {
        let index = self.getCurrentValuesIndex(second: Double(self.timelineView.timeSlider.value))
        if index == nil { return 0.0 }
        if index! < 0 || index! >= self.values.count { return 0.0 }
        return self.values[index!]
    }

    /**
     * return current vlaues index
     * @param second time from start
     * @return Int?
     **/
    private func getCurrentValuesIndex(second second: Double) -> Int? {
        if self.passes.count < 2 { return nil }

        let offset = self.passes.first!.timestamp.timeIntervalSinceDate(self.moveStartDate)
        let userDate = self.passes.first!.timestamp.dateByAddingTimeInterval(second)

        var index: Int? = nil
        for var i = 1; i < self.passes.count; i++ {
            let start = self.passes[i-1]
            let end = self.passes[i]
            if userDate.compare(start.timestamp) != .OrderedAscending && userDate.compare(end.timestamp) != .OrderedDescending {
                index = Int(second+offset) / 60
                break
            }
        }

        if index == nil { return index }
        if index! >= self.values.count { index = self.values.count-1 }
        if index! < 0 { index = 0 }

        return index
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
        self.timelineView.timeSliderTitleLabel.text = AIRSensorManager.sensorName(chemical: self.chemical)

        // mapview
        self.mapView.myLocationEnabled = true
        self.mapView.settings.myLocationButton = false
        self.mapView.frame = CGRectMake(
            self.mapView.frame.origin.x, self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height,
            self.mapView.frame.width, self.view.frame.height - (self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height + self.timelineView.timeSliderView.frame.height) + 36.0
        )
        self.mapView.padding = UIEdgeInsetsMake(0.0, 0.0, 36.0, 0.0)
        self.mapView.camera = GMSCameraPosition.cameraWithLatitude(
            37.7833,
            longitude: -122.4167,
            zoom: AIRGoogleMap.Zoom.Default
        )
        self.mapView.settings.myLocationButton = true
    }

    /**
     * update sensor values
     **/
    private func updateSensorValues() {
        self.NO2ValuePerMinutes = AIRSummary.sharedInstance.NO2ValuePerMinutes
        self.PM25ValuePerMinutes = AIRSummary.sharedInstance.PM25ValuePerMinutes
        self.UVValuePerMinutes = AIRSummary.sharedInstance.UVValuePerMinutes
        self.COValuePerMinutes = AIRSummary.sharedInstance.COValuePerMinutes
        self.SO2ValuePerMinutes = AIRSummary.sharedInstance.SO2ValuePerMinutes
        self.O3ValuePerMinutes = AIRSummary.sharedInstance.O3ValuePerMinutes

        self.setPasses(AIRSummary.sharedInstance.passes)
        self.sensors = AIRSummary.sharedInstance.sensors.filter({ (sensor: AIRSensor) -> Bool in
            return sensor.name == self.chemical
        })
    }

    /**
     * update map and timeline
     **/
    private func updateMapAndTimeline() {
        self.setSensorValues()
        self.designPassesSwitchButtons()

        if AIRMapCamera.sharedInstance.hasCurrentCamera() { self.mapView.camera = AIRMapCamera.sharedInstance.currentCamera()}
        else if self.passes.count < 2 { self.mapView.moveCameraToMyLocation() }
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
            let date = self.passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart).air_minutesAgo(minutes: -1)!
            //let date = self.passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)
            let dateFormatter = NSDateFormatter.air_dateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            time = dateFormatter.stringFromDate(date)

            color = AIRSensorManager.sensorColor(value: self.currentValue(), sensorBasements: self.basements)

            self.timelineView.setDate(date)
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

        self.timelineView.initTimelabels(passes: passes)
        self.timelineView.timeSliderContentView.hidden = true

        if self.values.count == 0 { return }
        let startIndex = self.getCurrentValuesIndex(second: 0.0)
        let endIndex = self.getCurrentValuesIndex(second: allInterval)
        if startIndex == nil || endIndex == nil { return }

        let valuesPerMinute = self.values.slice((startIndex!), (endIndex!))
        self.timelineView.setLineChart(
            passes: self.passes,
            valuesPerMinute: valuesPerMinute,
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

    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        //// get request params
        //let previousCameraBounds = self.cameraBounds
        //self.cameraBounds = self.mapView.cameraBounds()
        //if previousCameraBounds == self.cameraBounds { return }

        //let lat = self.cameraBounds!.northEast.latitude - self.cameraBounds!.southWest.latitude
        //let lng = self.cameraBounds!.northEast.longitude - self.cameraBounds!.southWest.longitude
        //var radius = AIRSensorPolygon.Radiuses[0]
        //for var i = 0; i < AIRSensorPolygon.Radiuses.count; i++ {
        //    let r = AIRSensorPolygon.Radiuses[i]
        //    let squareCount = (lat / r) * (lng / r)
        //    if squareCount <= AIRSensorPolygon.ThresholdOfPolygons { break }
        //    radius = r
        //}
        //AIRLOG("\(position.target), \(position.zoom), \(position.bearing), \(position.viewingAngle)")
        //// request
        //AIRSensorClient.sharedInstance.getSensorValues(
        //    name: self.chemical,
        //    minimumLocation: self.cameraBounds!.southWest,
        //    maximumLocation: self.cameraBounds!.northEast,
        //    radius: ,
        //    date: NSDate(),
        //    completionHandler: { (json: JSON) -> Void

        //        NSNotificationCenter.defaultCenter().postNotificationName(
        //            AIRNotificationCenter.DidUpdateMapSensors,
        //            object: ,
        //            userInfo: [:]
        //        )
        //    }
        //)
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
