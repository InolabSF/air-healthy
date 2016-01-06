/// MARK: - AIRChemicalGraphViewDelegate
@objc protocol AIRChemicalGraphViewDelegate {

    /**
     * called when button is touched up inside
     * @param chemicalGraphView AIRChemicalGraphView
     * @param button UIButton
     */
    func touchedUpInside(chemicalGraphView chemicalGraphView: AIRChemicalGraphView, button: UIButton)

}


/// MARK: - AIRChemicalGraphView
class AIRChemicalGraphView: UIView {

    /// MARK: - property

    @IBOutlet weak var delegate: AnyObject?

    @IBOutlet weak var O3View: UIView!
    @IBOutlet weak var O3PieChartView: VBPieChart!
    @IBOutlet weak var O3Button: UIButton!

    @IBOutlet weak var SO2View: UIView!
    @IBOutlet weak var SO2PieChartView: VBPieChart!
    @IBOutlet weak var SO2Button: UIButton!

    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var summaryIconView: UIView!
    @IBOutlet weak var summaryLabel: UILabel!


    /// MARK: - destruction

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("setChemicalButtonImages:"),
            name: AIRNotificationCenter.SetChemicalButtonImages,
            object: nil
        )

        self.setUp()
    }


    /// MARK: - notification

    func setChemicalButtonImages(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.O3Button.setImage(UIImage.imageFromView(self.O3PieChartView), forState: .Normal)
            self.SO2Button.setImage(UIImage.imageFromView(self.SO2PieChartView), forState: .Normal)
        })
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
        if self.delegate != nil {
            (self.delegate as! AIRChemicalGraphViewDelegate).touchedUpInside(chemicalGraphView: self, button: button)
        }
    }


    /// MARK: - public api

    /**
     * set sensor values to pie chart
     * @param SO2AverageSensorValues
     * @param O3AverageSensorValues
     **/
    func setSensorValues(SO2AverageSensorValues SO2AverageSensorValues: [Double], O3AverageSensorValues: [Double]) {
        var airHealth = [0.0]

        airHealth = [0.0, 0.0, 0.0]
        if SO2AverageSensorValues.count == 0 { airHealth = [1.0, 0.0, 0.0] }
        for var i = 0; i < SO2AverageSensorValues.count; i++ {
            let value = SO2AverageSensorValues[i]
            if value < AIRSensorManager.WHOBasementSO2_1 { airHealth[0] += 1.0 }
            else if value < AIRSensorManager.WHOBasementSO2_2 { airHealth[1] += 1.0 }
            else { airHealth[2] += 1.0 }
        }
        self.setPieChart(self.SO2PieChartView, airHealth: airHealth, animated: true)

        airHealth = [0.0, 0.0, 0.0]
        if O3AverageSensorValues.count == 0 { airHealth = [1.0, 0.0, 0.0] }
        for var i = 0; i < O3AverageSensorValues.count; i++ {
            let value = O3AverageSensorValues[i]
            if value < AIRSensorManager.WHOBasementOzone_S_1 { airHealth[0] += 1.0 }
            else if value < AIRSensorManager.WHOBasementOzone_S_2 { airHealth[1] += 1.0 }
            else { airHealth[2] += 1.0 }
        }
        self.setPieChart(self.O3PieChartView, airHealth: airHealth, animated: true)

        // button
        let after = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(after, dispatch_get_main_queue(), {
            // notification
            NSNotificationCenter.defaultCenter().postNotificationName(
                AIRNotificationCenter.SetChemicalButtonImages,
                object: nil,
                userInfo: [:]
            )
        })
    }


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        let paragraph = "You had some negative exposure to O3 and SO2. Long exposure to these harmful gas can lead to asthma. Find an alternative route next time or leave after the rush hour to avoid these harmful gas."
        self.summaryLabel.attributedText = paragraph.air_justifiedString(font: self.summaryLabel.font)
        self.summaryLabel.textAlignment = NSTextAlignment.Justified
        self.summaryLabel.preferredMaxLayoutWidth = self.summaryLabel.frame.width

        let chartViews = [self.O3PieChartView, self.SO2PieChartView]
        for chartView in chartViews {
            chartView.layer.cornerRadius = chartView.frame.size.width / 2.0
            chartView.layer.masksToBounds = true
            chartView.clipsToBounds = true
        }
        let containerViews = [self.O3View, self.SO2View]
        for containerView in containerViews {
            containerView.layer.shadowOffset = CGSizeMake(0, 0)
            containerView.layer.shadowOpacity = 0.15
            containerView.layer.shadowRadius = 2.0
            containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.bounds.width/2.0).CGPath
        }

        self.summaryIconView.layer.cornerRadius = 18.0
        self.summaryIconView.layer.masksToBounds = true
        self.summaryIconView.clipsToBounds = true
        self.summaryView.layer.shadowOffset = CGSizeMake(0, 0)
        self.summaryView.layer.shadowOpacity = 0.3
        self.summaryView.layer.shadowRadius = 2.0
        self.summaryView.layer.shadowPath = UIBezierPath(
            roundedRect: CGRectMake(self.summaryView.bounds.origin.x, self.summaryView.bounds.origin.y, UIScreen.mainScreen().bounds.width, self.summaryView.bounds.height),
            cornerRadius: 18.0
        ).CGPath
    }


    /**
     * set datas
     * @param pieChartView VBPieChart
     * @param airHealth [Double]
     * @param animated Bool
     **/
    func setPieChart(pieChartView: VBPieChart, airHealth: [Double], animated: Bool) {
        // button
        self.O3Button.setImage(nil, forState: .Normal)
        self.SO2Button.setImage(nil, forState: .Normal)

        // pie chart
        pieChartView.enableStrokeColor = true
        pieChartView.holeRadiusPrecent = 0.5
        pieChartView.labelsPosition = VBLabelsPosition.OnChart
        pieChartView.startAngle = Float(M_PI / 2.0 * 3.0)

        let values = [
            [ // healthy
                "name" : "",
                "value" : NSNumber(double: airHealth[0]),
                "color" : UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            ],
            [ // warning
                "name" : "",
                "value" : NSNumber(double: airHealth[1]),
                "color" : UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
            ],
            [ // unhealthy
                "name" : "",
                "value" : NSNumber(double: airHealth[2]),
                "color" : UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
            ],
        ]
        pieChartView.setChartValues(
            values,
            animation: animated,
            duration: 0.8,
            options: [.FanAll, .TimingEaseIn]
        )
    }

}
