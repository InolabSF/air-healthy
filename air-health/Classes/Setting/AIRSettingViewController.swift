/// MARK: - AIRSettingViewController
class AIRSettingViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    @IBOutlet weak var GPSSwitch: UISwitch!
    @IBOutlet weak var userSwitch: UISwitch!


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        // status bar
        UIApplication.sharedApplication().statusBarStyle = .Default

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

        // User
        let userIsOn = NSUserDefaults().boolForKey(AIRUserDefaults.UserIsOn)
        self.userSwitch.on = userIsOn
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
        else if control == self.userSwitch {
            let userIsOn = self.userSwitch.on
            NSUserDefaults().setObject(userIsOn, forKey: AIRUserDefaults.UserIsOn)
            NSUserDefaults().synchronize()
            if !userIsOn {
                AIRUserClient.sharedInstance.postUser(
                    userIsOn: userIsOn,
                    location: CLLocation(latitude: 0.0, longitude: 0.0),
                    completionHandler: { (json) in
                    }
                )
            }
        }
    }


    /// MARK: - private api

}
