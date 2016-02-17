/// MARK: - AIRChemicalViewController
class AIRChemicalViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var graphView: AIRChemicalGraphView!


    /// MARK: - destruction

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        self.graphView.graphListView.hidden = false

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

        self.graphView.setSensorValues(
            NO2AverageSensorValues: AIRSummary.sharedInstance.NO2ValuePerMinutes,
            PM25AverageSensorValues: AIRSummary.sharedInstance.PM25ValuePerMinutes,
            UVAverageSensorValues: AIRSummary.sharedInstance.UVValuePerMinutes,
            COAverageSensorValues: AIRSummary.sharedInstance.COValuePerMinutes,
            SO2AverageSensorValues: AIRSummary.sharedInstance.SO2ValuePerMinutes,
            O3AverageSensorValues: AIRSummary.sharedInstance.O3ValuePerMinutes
        )

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == AIRNSStringFromClass(AIRMapViewController)) {
            let chemical = sender as! String
            let vc = segue.destinationViewController as! AIRMapViewController
            vc.chemical = chemical
        }
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

    /**
     * get sensor datas
     * @param notification NSNotification
     **/
    func didUpdateSensorValues(notificatoin: NSNotification) {
        self.graphView.setSensorValues(
            NO2AverageSensorValues: AIRSummary.sharedInstance.NO2ValuePerMinutes,
            PM25AverageSensorValues: AIRSummary.sharedInstance.PM25ValuePerMinutes,
            UVAverageSensorValues: AIRSummary.sharedInstance.UVValuePerMinutes,
            COAverageSensorValues: AIRSummary.sharedInstance.COValuePerMinutes,
            SO2AverageSensorValues: AIRSummary.sharedInstance.SO2ValuePerMinutes,
            O3AverageSensorValues: AIRSummary.sharedInstance.O3ValuePerMinutes
        )
    }


    /// MARK: - public api


    /// MARK: - private api

}


/// MARK: - AIRChemicalGraphViewDelegate
extension AIRChemicalViewController: AIRChemicalGraphViewDelegate {

    func touchedUpInside(chemicalGraphView chemicalGraphView: AIRChemicalGraphView, chemical: String) {
        self.performSegueWithIdentifier(AIRNSStringFromClass(AIRMapViewController), sender: chemical)
    }

}

