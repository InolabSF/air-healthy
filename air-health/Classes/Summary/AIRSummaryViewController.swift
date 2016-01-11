/// MARK: - AIRSummaryViewController
class AIRSummaryViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    @IBOutlet weak var loadingView: AIRLoadingView!
    @IBOutlet weak var summaryView: AIRSummaryView!


    /// MARK: - destruction

    deinit {
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        if AIRTutorialManager.sharedInstance.willBeTutorial() {
            let window = UIApplication.sharedApplication().keyWindow
            AIRTutorialManager.sharedInstance.start(parentView: window!)
        }

        self.setUp()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == AIRNSStringFromClass(AIRChemicalViewController)) {
            let vc = segue.destinationViewController as! AIRChemicalViewController
            vc.SO2AverageSensorValues = AIRSummary.sharedInstance.SO2ValuePerMinutes
            vc.O3AverageSensorValues = AIRSummary.sharedInstance.O3ValuePerMinutes
            vc.passes = AIRSummary.sharedInstance.passes
            vc.sensors = AIRSummary.sharedInstance.sensors
        }
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
    }


    /// MARK: - notification


    /// MARK: - private api

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

        AIRSummary.sharedInstance.delegate = self
        AIRSummary.sharedInstance.setSensorValues()
        AIRSummary.sharedInstance.getSensorsFromServer()
    }

}


/// MARK: - AIRSummaryViewDelegate
extension AIRSummaryViewController: AIRSummaryViewDelegate {

    func touchedUpInside(summaryView summaryView: AIRSummaryView, button: UIButton) {
        self.performSegueWithIdentifier(AIRNSStringFromClass(AIRChemicalViewController), sender: nil)
    }

}


/// MARK: - AIRSummaryDelegate
extension AIRSummaryViewController: AIRSummaryDelegate {

    func summaryCalculationDidStart(summary summary: AIRSummary) {
        self.loadingView.startAnimation()
    }

    func summaryCalculationDidEnd(summary summary: AIRSummary) {
        self.loadingView.stopAnimation()
        self.summaryView.setValues(AIRSummary.sharedInstance.values)
    }

}
