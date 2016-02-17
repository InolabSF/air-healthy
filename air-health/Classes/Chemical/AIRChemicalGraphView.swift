@objc protocol AIRChemicalGraphViewDelegate {

    /**
     * called when button is touched up inside
     * @param chemicalGraphView AIRChemicalGraphView
     * @param chemical String
     */
    func touchedUpInside(chemicalGraphView chemicalGraphView: AIRChemicalGraphView, chemical: String)

}


/// MARK: - AIRChemicalGraphView
class AIRChemicalGraphView: UIView {

    /// MARK: - property

    @IBOutlet weak var delegate: AnyObject?

    var chemicals = [
        "SO2", "Ozone_S", "NO2", "PM25", "CO", "UV",
    ]
    var airHealths = [
        [1.0, 0.0, 0.0],
        [1.0, 0.0, 0.0],
        [1.0, 0.0, 0.0],
        [1.0, 0.0, 0.0],
        [1.0, 0.0, 0.0],
        [1.0, 0.0, 0.0],
    ]

    @IBOutlet var graphListView: UIView!
    @IBOutlet var graphViews: [UIView]!
    @IBOutlet var pieChartViews: [VBPieChart]!
    @IBOutlet var graphButtons: [UIButton]!


    /// MARK: - destruction

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUp()
    }


    /// MARK: - notification


    /// MARK: - event listener

    @IBAction func touchUpInside(button button: UIButton) {
        // graph button
        var index: Int? = nil
        for var i = 0; i < self.graphButtons.count; i++ {
            let gButton = self.graphButtons[i]
            if button == gButton {
                index = i
                break
            }
        }
        if index == nil { return }
        if self.delegate != nil {
            (self.delegate as! AIRChemicalGraphViewDelegate).touchedUpInside(chemicalGraphView: self, chemical: self.chemicals[index!])
        }
    }

    /// MARK: - public api

    /**
     * set sensor values to pie chart
     * @param NO2AverageSensorValues
     * @param PM25AverageSensorValues
     * @param UVAverageSensorValues
     * @param COAverageSensorValues
     * @param SO2AverageSensorValues
     * @param O3AverageSensorValues
     **/
    func setSensorValues(
        NO2AverageSensorValues NO2AverageSensorValues: [Double],
        PM25AverageSensorValues: [Double],
        UVAverageSensorValues: [Double],
        COAverageSensorValues: [Double],
        SO2AverageSensorValues: [Double],
        O3AverageSensorValues: [Double]
    ) {
        let values = [
            SO2AverageSensorValues,
            O3AverageSensorValues,
            NO2AverageSensorValues,
            PM25AverageSensorValues,
            COAverageSensorValues,
            UVAverageSensorValues,
        ]
        self.airHealths = [
            [0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0],
        ]
        for var i = 0; i < self.airHealths.count; i++ {
            if values[i].count == 0 { self.airHealths[i] = [1.0, 0.0, 0.0] }
            for var j = 0; j < values[i].count; j++ {
                let value = values[i][j]
                let basement = AIRSensorManager.sensorBasements(chemical: self.chemicals[i])
                if value < basement[0] { self.airHealths[i][0] += 1.0 }
                else if value < basement[1] { self.airHealths[i][1] += 1.0 }
                else { self.airHealths[i][2] += 1.0 }
            }
        }

        for var i = 0; i < self.pieChartViews.count; i++ {
            let chartView = self.pieChartViews[i]
            chartView.setPieChart(airHealth: self.airHealths[i], animated: false)
            self.graphButtons[i].setImage(UIImage.imageFromView(chartView), forState: .Normal)
        }
    }


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        for chartView in self.pieChartViews {
            chartView.layer.cornerRadius = chartView.frame.size.width / 2.0
            chartView.layer.masksToBounds = true
            chartView.clipsToBounds = true
        }
        for containerView in self.graphViews {
            containerView.layer.shadowOffset = CGSizeMake(0, 0)
            containerView.layer.shadowOpacity = 0.15
            containerView.layer.shadowRadius = 2.0
            containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.bounds.width/2.0).CGPath
        }
    }

//    /**
//     * set summary text
//     **/
//    private func setSummary() {
//        var paragraph = ""
//        let indexPath = self.getFocusedIndexPath()
//
//        if indexPath != nil {
//            let name = AIRSensorManager.sensorName(chemical: self.chemicals[indexPath!.row])
//            let airHealth = self.airHealths[indexPath!.row]
//            let isHealthy = ((airHealth[1] + airHealth[2]) / (airHealth[0] + airHealth[1] + airHealth[2])) < 0.30
//            let isNotDangerous = ((airHealth[1] + airHealth[2]) / (airHealth[0] + airHealth[1] + airHealth[2])) < 0.60
//            if isHealthy {
//                paragraph = "\(name) is below WHO recommendation. It is good for outdoor activities!"
//            }
//            else if isNotDangerous {
//                paragraph = "You had some negative exposure to \(name). Long exposure to \(name) can affect your health."
//            }
//            else {
//                paragraph = "You had serious exposure to \(name). Avoid being outside."
//            }
//        }
//        else { return }
//
//        let top = self.summaryLabel.frame.origin.y
//        self.summaryLabel.attributedText = paragraph.air_justifiedString(font: self.summaryLabel.font)
//        self.summaryLabel.textAlignment = NSTextAlignment.Justified
//        self.summaryLabel.preferredMaxLayoutWidth = self.summaryLabel.frame.width
//        self.summaryLabel.sizeToFit()
//        let center = CGPointMake(self.center.x, top + self.summaryLabel.frame.height / 2.0)
//        self.summaryLabel.center = center
//    }

}
