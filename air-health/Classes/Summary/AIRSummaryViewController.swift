/// MARK: - AIRSummaryViewController
class AIRSummaryViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var loadingView: AIRLoadingView!
    //@IBOutlet weak var scrollView: UIScrollView!

    //@IBOutlet weak var currentLocationView: AIRCurrentLocationView!
    //@IBOutlet weak var timelineView: AIRTimelineView!
    @IBOutlet weak var sensorGraphView: AIRSensorGraphView!
    @IBOutlet weak var summaryView: AIRSummaryView!
    //@IBOutlet weak var mapView: AIRMapView!

    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var summaryButton: UIButton!

    var passes: [CLLocation] = []
    var values: [Double] = []
    var sensors: [AIRSensor] = []
    //var users: [AIRUser] = []

    var SO2ValuePerMinutes: [Double] = []
    var O3ValuePerMinutes: [Double] = []


    /// MARK: - destruction

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        self.setUp()

        let today = NSDate()
        // passes and sensor datas
        let newLocations = AIRLocation.fetch(date: today)
        // should update passes?
        if self.passes.count == 0 || self.passes.last!.timestamp.compare(newLocations.last!.timestamp) != .OrderedSame {
            self.passes = newLocations
        }
        self.setSensorValues()
        // get new sensor values
        self.getSensorValues()
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
        if (segue.identifier == AIRNSStringFromClass(AIRChemicalViewController)) {
            let vc = segue.destinationViewController as! AIRChemicalViewController

            vc.SO2AverageSensorValues = self.SO2ValuePerMinutes
            vc.O3AverageSensorValues = self.O3ValuePerMinutes
            vc.passes = self.passes
            //vc.values = self.values
            vc.sensors = self.sensors
            //vc.users = self.users
        }
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
        self.graphButton.hidden = true
        self.summaryButton.hidden = true

        if button == self.graphButton {
            self.summaryButton.hidden = false
            self.summaryView.hidden = false
        }
        else if button == self.summaryButton {
            self.graphButton.hidden = false
            self.summaryView.hidden = true
        }
    }


    /// MARK: - notification

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
        // get new sensor values
        self.getSensorValues()
    }

    /**
     * open map
     * @param notification NSNotification
     **/
    func openMapNotification(notification: NSNotification) {
        //self.timelineView.touchUpInside(button: self.timelineView.openButton)
        //self.mapView.moveCameraToMyLocation()
    }


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        //self.automaticallyAdjustsScrollViewInsets = false
        //self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width * 2, self.scrollView.frame.height)
        //self.timelineView.timeSliderContentView.hidden = true

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
/*
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
        self.mapView.air_delegate = self
*/
        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("getSensorValuesNotificatoin:"),
            name: AIRNotificationCenter.UpdateSensorValues,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("openMapNotification:"),
            name: AIRNotificationCenter.LaunchFromBadAirWarning,
            object: nil
        )
    }

    /**
     * draw map
     **/
/*
    private func drawMap() {
        self.mapView.draw(
            passes: self.passes,
            intervalFromStart: Double(self.timelineView.timeSlider.value),
            color: self.sensorGraphView.gaugeColor,
            sensors: self.sensors,
            users: self.users
        )
    }
*/

    /**
     * set timeline
     * @param sensorGraphButton AIRSensorGraphView's button
     **/
/*
    private func setTimeline() {
        let intervalFromStart = Double(self.timelineView.timeSlider.value)

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

        self.timelineView.setTimeline(time: time, color: self.sensorGraphView.gaugeColor)
    }
*/

    /**
     * get sensor datas
     * @param notification NSNotification
     **/
    func getSensorValues() {
/*
        // get sensor data from server if need
        AIRSensorClient.sharedInstance.getSensorValues(
            locations: self.passes,
            completionHandler: { [unowned self] (objects: [PFObject]?, error: NSError?) -> Void in
                AIRSensor.deleteAll()
                AIRSensor.save(objects: objects)
                self.setSensorValues()
            }
        )
*/
        AIRSensorClient.sharedInstance.getSensorValues(
            locations: self.passes,
            completionHandler: { [unowned self] (json: JSON) -> Void in
                AIRSensor.deleteAll()
                AIRSensor.save(json: json)
                self.setSensorValues()
            }
        )

    }

    /**
     * set sensor datas
     **/
    private func setSensorValues() {
        self.loadingView.startAnimation()

        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) / 10.0)),
            dispatch_get_main_queue(),
            { [unowned self] () in



        let today = NSDate()

        // sensors
        let southWest = AIRLocation.southWest(locations: self.passes, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
        let northEast = AIRLocation.northEast(locations: self.passes, offsetMeters: AIRLocationManager.ThresholdOfSensorNeighbor)
        //self.sensors = AIRSensor.fetch(name: "Ozone_S", date: today, southWest: southWest, northEast: northEast)
        //self.sensors += AIRSensor.fetch(name: "SO2", date: today, southWest: southWest, northEast: northEast)
        self.sensors = AIRSensor.fetch(date: today, southWest: southWest, northEast: northEast)
/*
        // timeline
        if self.passes.count > 0 {
            let allInterval = self.passes.last!.timestamp.timeIntervalSinceDate(self.passes.first!.timestamp)
            self.timelineView.timeSlider.maximumValue = CGFloat(allInterval)
            if self.timelineView.timeSlider.maximumValue > 0.0 { self.timelineView.timeSlider.value = self.timelineView.timeSlider.maximumValue }
        }
*/
        // values
        self.SO2ValuePerMinutes = AIRSensorManager.valuesPerMinute(
            passes: self.passes,
            averageSensorValues: AIRSensorManager.averageSensorValues(name: "SO2", date: today, locations: self.passes),
            sensorBasements: AIRSensorManager.sensorBasements(name: "SO2")
        )
        self.O3ValuePerMinutes = AIRSensorManager.valuesPerMinute(
            passes: self.passes,
            averageSensorValues: AIRSensorManager.averageSensorValues(name: "Ozone_S", date: today, locations: self.passes),
            sensorBasements: AIRSensorManager.sensorBasements(name: "Ozone_S")
        )
        self.values = []
        for var i = 0; i < self.SO2ValuePerMinutes.count; i++ {
            let so2 = abs(self.SO2ValuePerMinutes[i] / AIRSensorManager.WHOBasementSO2_2)
            let o3 = abs(self.O3ValuePerMinutes[i] / AIRSensorManager.WHOBasementOzone_S_2)
            let value = so2 + o3
            self.values.append(value)
        }

        // summary
        self.summaryView.setValues(self.values)

        // graph
        self.sensorGraphView.gaugeView.value = 0.0
        if self.values.count > 0 {
            self.sensorGraphView.gaugeView.value = CGFloat(self.values.last!)
            self.sensorGraphView.sensorLabel.text = String(format: "SO2: %.1f\nO3: %.1f", self.SO2ValuePerMinutes[0], self.O3ValuePerMinutes[0])
        }
/*
        // timeline
        self.timelineView.setLineChart(
            passes: self.passes,
            valuesPerMinute: self.values,
            sensorBasements: AIRSensorManager.sensorBasements()
        )
        self.setTimeline()
*/
        self.loadingView.stopAnimation()




            }
        )
    }
}


/// MARK: - GMSMapViewDelegate
/*
extension AIRSummaryViewController: GMSMapViewDelegate {

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
*/
/*
// MARK: - AIRMapViewDelegate
extension AIRSummaryViewController: AIRMapViewDelegate {

    func touchedUpInside(mapView mapView: AIRMapView, button: UIButton) {
        self.drawMap()
    }

}
*/

/*
/// MARK: - AIRTimelineViewDelegate
extension AIRSummaryViewController: AIRTimelineViewDelegate {

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

    func touchedUpInside(timelineView timelineView: AIRTimelineView, closeButton: UIButton) {
        self.sensorGraphView.toggle(
            hidden: false,
            animationHandler: { () in },
            completionHandler:{ () in }
        )
    }

    func valueChanged(timelineView timelineView: AIRTimelineView, control: GradientSlider) {
        if self.passes.count >= 2 {
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
                self.sensorGraphView.gaugeView.value = CGFloat(self.values[index])
                self.sensorGraphView.sensorLabel.text = String(format: "SO2: %.1f\nO3: %.1f", self.SO2ValuePerMinutes[index], self.O3ValuePerMinutes[index])
            }
        }

        //self.drawMap() // draw map
        self.setTimeline() // timeline
    }

}
*/

/// MARK: - AIRSummaryViewDelegate
extension AIRSummaryViewController: AIRSummaryViewDelegate {

    func touchedUpInside(summaryView summaryView: AIRSummaryView, button: UIButton) {
        self.performSegueWithIdentifier(AIRNSStringFromClass(AIRChemicalViewController), sender: nil)
    }

}
///// MARK: - AIRSummaryViewController
//class AIRSummaryViewController: UIViewController {
//
//    /// MARK: - property
//
//    let headerNib = UINib(nibName: AIRNSStringFromClass(AIRSummaryCollectionCell), bundle: NSBundle.mainBundle())
//    @IBOutlet weak var collectionView: UICollectionView!
//    var section = [
//            [
//                "Song 1",
//                "Song 2",
//                "Song 3",
//                "Song 4",
//                "Song 5",
//                "Song 6",
//                "Song 7",
//                "Song 8",
//                "Song 9",
//                "Song 10",
//                "Song 11",
//                "Song 12",
//                "Song 13",
//                "Song 14",
//                "Song 15",
//                "Song 16",
//                "Song 17",
//                "Song 18",
//                "Song 19",
//                "Song 20",
//            ]
//        ]
//
//    /// MARK: - destruction
//
//    deinit {
//    }
//
//
//    /// MARK: - life cycle
//
//    override func loadView() {
//        super.loadView()
//
//        if let layout: IOStickyHeaderFlowLayout = self.collectionView.collectionViewLayout as? IOStickyHeaderFlowLayout {
//            layout.parallaxHeaderReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 274)
//            layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 180)
//            layout.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, layout.itemSize.height)
//            layout.parallaxHeaderAlwaysOnTop = true
//            layout.disableStickyHeaders = true
//            self.collectionView.collectionViewLayout = layout
//        }
//
//        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
//        self.collectionView.registerNib(self.headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader, withReuseIdentifier: "header")
//    }
//
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//
//    /// MARK: - event listener
//
//    /**
//     * called when button is touched up inside
//     * @param button UIButton
//     **/
//    @IBAction func touchUpInside(button button: UIButton) {
//    }
//
//
//    /// MARK: - notification
//
//
//    /// MARK: - private api
//}
//
//
///// MARK: - UICollectionViewDataSource
//extension AIRSummaryViewController: UICollectionViewDataSource {
//}
//
//
///// MARK: - UICollectionViewDelegate
//extension AIRSummaryViewController: UICollectionViewDelegate {
//
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return self.section.count
//    }
//
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.section[section].count
//    }
//
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
//        return cell
//    }
//
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSizeMake(UIScreen.mainScreen().bounds.size.width, 50);
//    }
//
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        switch kind {
//        case IOStickyHeaderParallaxHeader:
//            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath)
//            return cell
//        default:
//            assert(false, "Unexpected element kind")
//        }
//    }
//}
//
//
///// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
//extension AIRSummaryViewController: UICollectionViewDelegateFlowLayout {
//}
