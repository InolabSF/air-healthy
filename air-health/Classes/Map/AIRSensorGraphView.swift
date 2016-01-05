/// MARK: - AIRSensorGraphView
class AIRSensorGraphView: UIView {

    /// MARK: - constant


    /// MARK: - property

    var initialY: CGFloat = 0.0
    var gaugeColor = UIColor.clearColor()

    @IBOutlet weak var sensorLabel: UILabel!
    @IBOutlet weak var gaugeView: LMGaugeView!
    @IBOutlet weak var gaugeButton: UIButton!
    @IBOutlet weak var gaugeLabel: UILabel!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setUp()
        self.initialY = self.frame.origin.y
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchedUpInside(button button: UIButton) {
    }


    /// MARK: - notification


    /// MARK: - public api


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        self.gaugeView.showUnitOfMeasurement = false
        self.gaugeView.showLimitDot = false
        self.gaugeView.valueTextColor = UIColor.clearColor()
        self.gaugeView.backgroundColor = UIColor.clearColor()
        self.gaugeView.minValue = 0.0
        self.gaugeView.maxValue = 5.0
    }

    /**
     * show or hide
     * @param hidden Bool
     * @param animationHandler blocks
     * @param completionHandler blocks
     **/
    func toggle(hidden hidden: Bool, animationHandler: () -> Void, completionHandler: () -> Void) {
        // position
        let hiddenDestination = CGRectMake(
            self.frame.origin.x, self.frame.height,
            self.frame.width, self.frame.height
        )
        let shownDestination = CGRectMake(
            self.frame.origin.x, self.initialY,
            self.frame.width, self.frame.height
        )

        // start setting
        self.frame = (hidden) ? shownDestination : hiddenDestination
        self.hidden = false

        // animation
        UIView.animateWithDuration(
            (hidden) ? 0.25 : 0.20,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                animationHandler()
                self.frame = (hidden) ? hiddenDestination : shownDestination
            },
            completion: { [unowned self] finished in
                completionHandler()
                self.hidden = hidden
            }
        )
    }

}


/// MARK: - AIRSensorGraphView
extension AIRSensorGraphView: LMGaugeViewDelegate {
    func gaugeView(gaugeView: LMGaugeView, ringStokeColorForValue value: CGFloat) -> UIColor {
        self.gaugeColor = UIColor.clearColor()
        if value < CGFloat(AIRSensorManager.Basement_1) {
            self.gaugeButton.setImage(UIImage(named: "home_icon_good"), forState: .Normal)
            self.gaugeColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            self.gaugeLabel.text = "Good"
        }
        else if value < CGFloat(AIRSensorManager.Basement_2) {
            self.gaugeButton.setImage(UIImage(named: "home_icon_normal"), forState: .Normal)
            self.gaugeColor = UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
            self.gaugeLabel.text = "Normal"
        }
        else {
            self.gaugeButton.setImage(UIImage(named: "home_icon_bad"), forState: .Normal)
            self.gaugeColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
            self.gaugeLabel.text = "Bad"
        }
        return self.gaugeColor
    }
}
