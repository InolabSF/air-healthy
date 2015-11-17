/// MARK: - AIRMapViewController
class AIRMapViewController: UIViewController {

    /// MARK: - property
    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var mapView: AIRMapView!

    var stops: [CLLocation] = []
    var passes: [CLLocation] = []


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        // title
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName: UIFont(name: "AmericanTypewriter-Bold", size: 24)!
        ]

        // left bar button
        self.leftBarButton.setImage(
            IonIcons.imageWithIcon(
                ion_ios_arrow_back,
                iconColor: UIColor.grayColor(),
                iconSize: 22,
                imageSize: CGSizeMake(22, 22)),
            forState: .Normal
        )
        // right bar button
        self.rightBarButton.setImage(
            IonIcons.imageWithIcon(
                ion_android_settings,
                iconColor: UIColor.grayColor(),
                iconSize: 22,
                imageSize: CGSizeMake(22, 22)),
            forState: .Normal
        )

        // mapview
        self.mapView.myLocationEnabled = false
        self.mapView.settings.myLocationButton = false
        self.mapView.frame = UIScreen.mainScreen().bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // draw
        self.mapView.draw(passes: self.passes, stops: self.stops)
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
