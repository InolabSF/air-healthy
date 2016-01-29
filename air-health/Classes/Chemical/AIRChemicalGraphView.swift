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

    // A
    @IBOutlet weak var tableView: UITableView!
    //
    // B
    @IBOutlet var graphListView: UIView!
    @IBOutlet var graphViews: [UIView]!
    @IBOutlet var pieChartViews: [VBPieChart]!
    @IBOutlet var graphButtons: [UIButton]!
    //

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
        self.setUp()
        self.setSummary()
        self.setFocusedCell()
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

        // A
        self.tableView.reloadData()
        self.setFocusedCell()
        //
        // B
        for var i = 0; i < self.pieChartViews.count; i++ {
            let chartView = self.pieChartViews[i]
            chartView.setPieChart(airHealth: self.airHealths[i], animated: false)
            self.graphButtons[i].setImage(UIImage.imageFromView(chartView), forState: .Normal)
        }
        //

        self.setSummary()
    }


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        // A
        // tableView
        (self.tableView as UIScrollView).delegate = self
            // inset
        //let centerY = (self.frame.height - self.summaryView.frame.height) / 2.0 + self.tableView.center.y - ((self.frame.height - self.summaryView.frame.height) / 2.0)
        //let top = centerY - AIRChemicalGraphTableViewcell.air_height() / 2.0
        //let bottom = centerY - AIRChemicalGraphTableViewcell.air_height() / 2.0
        let top = self.tableView.center.y - AIRChemicalGraphTableViewcell.air_height() / 2.0
        let bottom = self.tableView.center.y - AIRChemicalGraphTableViewcell.air_height() / 2.0
        self.tableView.contentInset = UIEdgeInsetsMake(top, 0.0, bottom, 0.0)
        //

        // B
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
        //

        // summary
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
     * set summary text
     **/
    private func setSummary() {
        var paragraph = ""
        let indexPath = self.getFocusedIndexPath()

        if indexPath != nil {
            let name = AIRSensorManager.sensorName(chemical: self.chemicals[indexPath!.row])
            let airHealth = self.airHealths[indexPath!.row]
            let isHealthy = ((airHealth[1] + airHealth[2]) / (airHealth[0] + airHealth[1] + airHealth[2])) < 0.30
            let isNotDangerous = ((airHealth[1] + airHealth[2]) / (airHealth[0] + airHealth[1] + airHealth[2])) < 0.60
            if isHealthy {
                paragraph = "\(name) is below WHO recommendation. It is good for outdoor activities!"
            }
            else if isNotDangerous {
                paragraph = "You had some negative exposure to \(name). Long exposure to \(name) can affect your health."
            }
            else {
                paragraph = "You had serious exposure to \(name). Avoid being outside."
            }
        }
        else { return }

        let top = self.summaryLabel.frame.origin.y
        self.summaryLabel.attributedText = paragraph.air_justifiedString(font: self.summaryLabel.font)
        self.summaryLabel.textAlignment = NSTextAlignment.Justified
        self.summaryLabel.preferredMaxLayoutWidth = self.summaryLabel.frame.width
        self.summaryLabel.sizeToFit()
        let center = CGPointMake(self.center.x, top + self.summaryLabel.frame.height / 2.0)
        self.summaryLabel.center = center
    }

    /**
     * get focused indexPath
     * @return NSIndexPath?
     **/
    private func getFocusedIndexPath() -> NSIndexPath? {
        let centerY = self.tableView.contentInset.top + AIRChemicalGraphTableViewcell.air_height() / 2.0
        return self.tableView.indexPathForRowAtPoint(CGPointMake(self.tableView.center.x, self.tableView.contentOffset.y+centerY))
    }

    /**
     * set focused cell
     **/
    private func setFocusedCell() {
        for cell in self.tableView.visibleCells {
            (cell as! AIRChemicalGraphTableViewcell).setContentViewColor(UIColor.whiteColor())
        }

        let indexPath = self.getFocusedIndexPath()
        if indexPath == nil { return }
        let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
        if cell == nil { return }
        (cell as! AIRChemicalGraphTableViewcell).setContentViewColor(UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0))
    }

}


/// MARK: - UITableViewDelegate, UITableViewDataSource
extension AIRChemicalGraphView: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chemicals.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = AIRChemicalGraphTableViewcell.air_cell()
        cell.setPieChart(chemical: AIRSensorManager.sensorName(chemical: self.chemicals[indexPath.row]), airHealth: self.airHealths[indexPath.row], animated: false)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if self.delegate != nil {
            (self.delegate as! AIRChemicalGraphViewDelegate).touchedUpInside(chemicalGraphView: self, chemical: self.chemicals[indexPath.row])
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return AIRChemicalGraphTableViewcell.air_height()
    }

}


/// MARK: - UIScrollViewDelegate
extension AIRChemicalGraphView: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.setSummary()
        self.setFocusedCell()
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetY = scrollView.contentOffset.y + velocity.y * 60.0
        let cellHeight = AIRChemicalGraphTableViewcell.air_height()
        let top = self.tableView.contentInset.top

        var targetIndex = round((targetY + top) / cellHeight)
        if targetIndex > CGFloat(self.chemicals.count) { targetIndex = CGFloat(self.chemicals.count) }
        else if targetIndex < 0.0 { targetIndex = 0.0 }
        targetContentOffset.memory.y = -top + targetIndex * cellHeight
    }
}
