/// MARK: - AIRSensorGraphViewDelegate
@objc protocol AIRSensorGraphViewDelegate {

    /**
     * called when button is touched up inside
     * @param sensorGraphView AIRSensorGraphView
     * @param button UIButton
     */
    func touchedUpInside(sensorGraphView sensorGraphView: AIRSensorGraphView, button: UIButton)

}


/// MARK: - AIRSensorGraphView
class AIRSensorGraphView: UIView {

    /// MARK: - property

    @IBOutlet weak var delegate: AnyObject?

    @IBOutlet weak var O3PieChartView: VBPieChart!
    @IBOutlet weak var O3Button: UIButton!

    @IBOutlet weak var SO2PieChartView: VBPieChart!
    @IBOutlet weak var SO2Button: UIButton!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.O3Button.layer.cornerRadius = self.O3Button.frame.size.width / 2.0
        self.O3Button.layer.masksToBounds = true
        self.SO2Button.layer.cornerRadius = self.SO2Button.frame.size.width / 2.0
        self.SO2Button.layer.masksToBounds = true
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
        if self.delegate != nil {
            (self.delegate as! AIRSensorGraphViewDelegate).touchedUpInside(sensorGraphView: self, button: button)
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
        for var i = 0; i < SO2AverageSensorValues.count; i++ {
            let value = SO2AverageSensorValues[i]
            if value < AIRSensorManager.WHOBasementSO2_1 { airHealth[0] += 1.0 }
            else if value < AIRSensorManager.WHOBasementSO2_2 { airHealth[1] += 1.0 }
            else { airHealth[2] += 1.0 }
        }
        self.setPieChart(self.SO2PieChartView, airHealth: airHealth, animated: true)

        airHealth = [0.0, 0.0, 0.0]
        for var i = 0; i < O3AverageSensorValues.count; i++ {
            let value = O3AverageSensorValues[i]
            if value < AIRSensorManager.WHOBasementOzone_S_1 { airHealth[0] += 1.0 }
            else if value < AIRSensorManager.WHOBasementOzone_S_2 { airHealth[1] += 1.0 }
            else { airHealth[2] += 1.0 }
        }
        self.setPieChart(self.O3PieChartView, airHealth: airHealth, animated: true)
    }


    /// MARK: - private api

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

        // button
        let after = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(after, dispatch_get_main_queue(), { [unowned self] in
            self.O3Button.setImage(UIImage.imageFromView(self.O3PieChartView), forState: .Normal)
            self.SO2Button.setImage(UIImage.imageFromView(self.SO2PieChartView), forState: .Normal)
        })
    }

}
