/// MARK: - AIRMapViewController
class AIRMapViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var timelineView: AIRTimelineView!
    @IBOutlet weak var sensorGraphView: AIRSensorGraphView!
    @IBOutlet weak var mapView: AIRMapView!

    var passes: [CLLocation] = []
    var selectedSensorButton: UIButton?
    var SO2AverageSensorValues: [Double] = []
    var O3AverageSensorValues: [Double] = []


    /// MARK: - destruction

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

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
                iconColor: UIColor.clearColor(),
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

        // mapview
        self.mapView.myLocationEnabled = false
        self.mapView.settings.myLocationButton = false
        self.mapView.frame = CGRectMake(
            //self.mapView.frame.origin.x, self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height,
            //self.mapView.frame.width, self.view.frame.height - (self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height)
            self.mapView.frame.origin.x, self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height,
            self.mapView.frame.width, self.view.frame.height - (self.timelineView.dateView.frame.origin.y + self.timelineView.dateView.frame.height + self.timelineView.timeSliderView.frame.height) + 36.0
        )

        self.mapView.camera = GMSCameraPosition.cameraWithLatitude(
            37.7833,
            longitude: -122.4167,
            zoom: 13.0
        )

        //self.timelineView.setUp()
        //self.sensorGraphView.setUp()

        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("getSensorValuesNotificatoin:"),
            name: AIRNotificationCenter.UpdateSensorValues,
            object: nil
        )
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        //AIRSensor.deleteAll()

        let today = NSDate()

        // passes and sensor datas
        let newLocations = AIRLocation.fetch(date: today)
        // should update passes?
        if self.passes.count == 0 || self.passes.last!.timestamp.compare(newLocations.last!.timestamp) != .OrderedSame {
            self.passes = newLocations
        }
        self.setSensorValues()

        self.getSensorValues()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
        if button == self.leftBarButton { self.navigationController!.popViewControllerAnimated(true) }
        else if button == self.rightBarButton { }
    }


    /// MARK: - private api

    /**
     * return averageSensorValues
     * @return averageSensorValues [Double]
     **/
    private func averageSensorValues() -> [Double] {
        var averages = [0.0]
        if self.selectedSensorButton == self.sensorGraphView.SO2Button {
            averages = SO2AverageSensorValues
        }
        else if self.selectedSensorButton == self.sensorGraphView.O3Button {
            averages = O3AverageSensorValues
        }
        return averages
    }

    /**
     * return sensorBasements
     * @return sensorBasements [Double]
     **/
    private func sensorBasements() -> [Double] {
        var basements = [0.0]
        if self.selectedSensorButton == self.sensorGraphView.SO2Button {
            basements = [AIRSensorManager.WHOBasementSO2_1, AIRSensorManager.WHOBasementSO2_2]
        }
        else if self.selectedSensorButton == self.sensorGraphView.O3Button {
            basements = [AIRSensorManager.WHOBasementOzone_S_1, AIRSensorManager.WHOBasementOzone_S_2]
        }
        return basements
    }

    /**
     * draw map
     **/
    private func drawMap() {
        let averages = self.averageSensorValues()
        let basements = self.sensorBasements()
        self.mapView.draw(
            passes: self.passes,
            intervalFromStart: Double(self.timelineView.timeSlider.value),
            averageSensorValues: averages,
            sensorBasements: basements
        )
    }

    /**
     * set timeline
     * @param sensorGraphButton AIRSensorGraphView's button
     **/
    private func setTimeline() {
        let intervalFromStart = Double(self.timelineView.timeSlider.value)
        let averages = self.averageSensorValues()
        let basements = self.sensorBasements()

        // time
        var time = ""
        if self.passes.count > 0 {
            let allInterval = self.passes.last!.timestamp.timeIntervalSinceDate(self.passes.first!.timestamp)
            self.timelineView.timeSlider.maximumValue = CGFloat(allInterval)
            let date = self.passes.first!.timestamp.dateByAddingTimeInterval(intervalFromStart)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            time = dateFormatter.stringFromDate(date)
        }
        // color
        let color = AIRSensorManager.sensorColor(
            passes: self.passes,
            intervalFromStart: intervalFromStart,
            averageSensorValues: averages,
            sensorBasements: basements
        )
        self.timelineView.setTimeline(time: time, color: color)
    }

    /**
     * get sensor datas
     * @param notification NSNotification
     **/
    func getSensorValues() {
        // get sensor data from server if need
        AIRSensorClient.sharedInstance.getSensorValues(
            locations: self.passes,
            completionHandler: { [unowned self] (objects: [PFObject]?, error: NSError?) -> Void in
                AIRSensor.save(objects: objects)
                self.setSensorValues()
            }
        )
    }

    /**
     * get sensor datas
     * @param notification NSNotification
     **/
    func getSensorValuesNotificatoin(notificatoin: NSNotification) {
        let today = NSDate()
        // passes and sensor datas
        let newLocations = AIRLocation.fetch(date: today)
        // should update passes?
        if self.passes.count == 0 || self.passes.last!.timestamp.compare(newLocations.last!.timestamp) != .OrderedSame {
            self.passes = newLocations
            self.setSensorValues()
        }

        self.getSensorValues()
    }

    /**
     * set sensor datas
     **/
    private func setSensorValues() {
        let today = NSDate()
        let sensorDate = today.air_daysAgo(days: AIRSensorManager.DaysAgo)!
        self.SO2AverageSensorValues = AIRSensorManager.averageSensorValues(name: "SO2", date: sensorDate, locations: self.passes)
        self.O3AverageSensorValues = AIRSensorManager.averageSensorValues(name: "Ozone_S", date: sensorDate, locations: self.passes)
        // timeline
        if self.passes.count > 0 {
            let allInterval = self.passes.last!.timestamp.timeIntervalSinceDate(self.passes.first!.timestamp)
            self.timelineView.timeSlider.maximumValue = CGFloat(allInterval)
        }
        // sensor graph view
        self.sensorGraphView.setSensorValues(SO2AverageSensorValues: self.SO2AverageSensorValues, O3AverageSensorValues: self.O3AverageSensorValues)
    }

}


/// MARK: - GMSMapViewDelegate
extension AIRMapViewController: GMSMapViewDelegate {

    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    }

    func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
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


/// MARK: - AIRSensorGraphViewDelegate
extension AIRMapViewController: AIRSensorGraphViewDelegate {

    func touchedUpInside(sensorGraphView sensorGraphView: AIRSensorGraphView, button: UIButton) {
        if passes.count < 1 { return }

        self.selectedSensorButton = button
        var gas = ""
        if self.selectedSensorButton == self.sensorGraphView.SO2Button { gas = "SO2" }
        else if self.selectedSensorButton == self.sensorGraphView.O3Button { gas = "O3" }

        // timeline
        self.timelineView.timeSlider.value = 0
        self.setTimeline()
        let averages = self.averageSensorValues()
        let basements = self.sensorBasements()
        let values = AIRSensorManager.valuesPerMinute(passes: self.passes, averageSensorValues: averages, sensorBasements: basements)
        self.timelineView.setLineChart(
            passes: self.passes,
            valuesPerMinute: values,
            sensorBasements: basements,
            title: gas
        )

        // draw map
        self.drawMap()
        self.mapView.moveCamera(passes: self.passes)

        // animation
        self.sensorGraphView.alpha = 1.0
        self.timelineView.toggleTimeSlider(
            hidden: false,
            animationHandler: { [unowned self] in
                self.sensorGraphView.alpha = 0.0
            },
            completionHandler:{ () in
            }
        )
    }

}


/// MARK: - AIRTimelineViewDelegate
extension AIRMapViewController: AIRTimelineViewDelegate {

    func touchedUpInside(timelineView timelineView: AIRTimelineView, closeButton: UIButton) {
        // animation
        self.sensorGraphView.alpha = 0.0
        self.timelineView.toggleTimeSlider(
            hidden: true,
            animationHandler: { [unowned self] in
                self.sensorGraphView.alpha = 1.0
            },
            completionHandler:{ () in
            }
        )
    }

    func valueChanged(timelineView timelineView: AIRTimelineView, control: GradientSlider) {
        self.drawMap() // draw map
        self.setTimeline() // timeline
    }

}
