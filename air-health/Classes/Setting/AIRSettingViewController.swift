/// MARK: - AIRSettingViewController
class AIRSettingViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    @IBOutlet weak var GPSSwitch: UISwitch!


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        self.navigationController!.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)!,
            NSForegroundColorAttributeName: UIColor.darkGrayColor()
        ]

        // left bar button
        self.leftBarButton.setImage(
            IonIcons.imageWithIcon(
                ion_android_close,
                iconColor: UIColor.darkGrayColor(),
                iconSize: 22,
                imageSize: CGSizeMake(22, 22)),
            forState: .Normal
        )
        // right bar button
        self.rightBarButton.setImage(
            IonIcons.imageWithIcon(
                ion_android_settings,
                iconColor: UIColor.clearColor(),
                iconSize: 22,
                imageSize: CGSizeMake(22, 22)),
            forState: .Normal
        )

        // GPS
        let GPSIsOff = NSUserDefaults().boolForKey(AIRUserDefaults.GPSIsOff)
        self.GPSSwitch.on = !GPSIsOff
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchedUpInside(button button: UIButton) {
        if button == self.leftBarButton {
            self.navigationController!.dismissViewControllerAnimated(true, completion: {});
        }
    }

    /**
     * called when control's value is changed
     * @param control UISwitch
     **/
    @IBAction func valueChanged(control control: UISwitch) {
        if control == self.GPSSwitch {
            let GPSIsOff = !(self.GPSSwitch.on)
            NSUserDefaults().setObject(GPSIsOff, forKey: AIRUserDefaults.GPSIsOff)
            NSUserDefaults().synchronize()
            if GPSIsOff { AIRLocationManager.sharedInstance.stopUpdatingLocation() }
            else { AIRLocationManager.sharedInstance.startUpdatingLocation() }
        }
    }


    /// MARK: - private api

}
