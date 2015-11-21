import UIKit


/// MARK: - AIRGraphViewController
class AIRGraphViewController: UIViewController {

    /// MARK: - property
    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var SO2LineChart: FSLineChart!
    @IBOutlet weak var O3LineChart: FSLineChart!

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

        // scrollView
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.O3LineChart.frame.origin.y + self.O3LineChart.frame.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.displayLineCharts()
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
    @IBAction func touchUpInside(button button: UIButton) {
        if button == self.leftBarButton { self.navigationController!.popViewControllerAnimated(true) }
        else if button == self.rightBarButton { }
    }


    /// MARK: - private api

    /**
     * display line charts
     **/
    private func displayLineCharts() {
        // line charts
        let lineCharts = [self.SO2LineChart, self.O3LineChart]
        for lineChart in lineCharts { self.initLineChart(lineChart) }

        if self.passes.count <= 0 { return }

        let date = NSDate()

        let allMinutes = Int(passes.last!.timestamp.timeIntervalSinceDate(passes.first!.timestamp) / 60)
        var SO2Values: [CGFloat] = []
        //var O3Values: [CGFloat] = []

        // sensor value
        for var i = 0; i <= allMinutes; i++ {
            SO2Values.append(0.0)
            //O3Values.append(0.0)
        }

        var centers: [CLLocation] = []
        for var i = 1; i < passes.count; i++ {
            let startLocation = passes[i-1]
            let endLocation = passes[i]

            let center = CLLocation(
                latitude: (startLocation.coordinate.latitude + endLocation.coordinate.latitude) / 2.0,
                longitude: (startLocation.coordinate.longitude + endLocation.coordinate.longitude) / 2.0
            )
            centers.append(center)
        }

        let SO2AverageValues = AIRSensorManager.averageSensorValues(name: "SO2", date: date, locations: centers)
        for var i = 0; i < passes.count-1; i++ {
            let SO2Value = CGFloat(SO2AverageValues[i])
            //let O3Value =

            let startLocation = passes[i]
            let endLocation = passes[i+1]

            let startMinute = startLocation.timestamp.timeIntervalSinceDate(self.passes[0].timestamp) / 60.0
            let endMinute = endLocation.timestamp.timeIntervalSinceDate(self.passes[0].timestamp) / 60.0
            let start = Int(startMinute)
            let end = Int(endMinute)
            for var i = start+1; i < end; i++ {
                SO2Values[i] = SO2Value
                //O3Values[i] = O3Value
            }
            SO2Values[start] += CGFloat(Double(start+1) - startMinute) * SO2Value
            SO2Values[end] += CGFloat(endMinute - Double(end)) * SO2Value
            //O3Values[start] += CGFloat(Double(start+1) - startMinute) * O3Value
            //O3Values[end] += CGFloat(endMinute - Double(end)) * O3Value
        }

        for var i = 0; i <= allMinutes; i++ {
            if SO2Values[i] < 0.1 { SO2Values[i] = CGFloat(AIRSensorManager.WHOBasementSO2 / 2.0) }
        }

        self.setLineChart(self.SO2LineChart, valuesPerMinute: SO2Values, color: UIColor.blueColor())
        //self.setLineChart(self.O3LineChart, valuesPerMinute: O3Values, color: UIColor.blueColor())

        // WHO basement
        SO2Values = []
        //O3Values = []
        for var i = 0; i <= allMinutes; i++ {
            SO2Values.append(CGFloat(AIRSensorManager.WHOBasementSO2))
            //O3Values.append(CGFloat(AIRSensorManager.WHOBasementOzone_S))
        }
        self.setLineChart(self.SO2LineChart, valuesPerMinute: SO2Values, color: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0))
        //self.setLineChart(self.O3LineChart, valuesPerMinute: O3Values, color: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0))
    }

    /**
     * initialize line chart
     * @param lineChart line chart
     **/
    private func initLineChart(lineChart: FSLineChart) {
        lineChart.verticalGridStep = 5
        lineChart.horizontalGridStep = 5
        lineChart.fillColor = UIColor.clearColor()
        lineChart.lineWidth = 2
    }

    /**
     * set line chart
     * @param lineChart line chart
     * @param valuesPerMinute [CGFloat]
     * @param color UIColor
     **/
    private func setLineChart(lineChart: FSLineChart, valuesPerMinute: [CGFloat], color: UIColor) {
        let timestamp = self.passes.first!.timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        lineChart.verticalGridStep = 5
        lineChart.horizontalGridStep = 5
        lineChart.labelForIndex = { (item) in
            return dateFormatter.stringFromDate(timestamp.air_minutesAgo(minutes: -Int(item))!)
        }
        lineChart.labelForValue = { (value) in
            return "\(value)"
        }
        lineChart.lineWidth = 2
        lineChart.color = color
        lineChart.setChartData(valuesPerMinute)
    }

}
