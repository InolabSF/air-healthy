import UIKit


/// MARK: - AIRGraphViewController
class AIRGraphViewController: UIViewController {

    /// MARK: - property
    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var NO2LineChart: FSLineChart!
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

        let minutes = Int(passes.last!.timestamp.timeIntervalSinceDate(passes.first!.timestamp) / 60)
        var valuesPerMinute: [CGFloat]
        var value = CGFloat(0)

        valuesPerMinute = []
        value = CGFloat(300)
        for var i = 0; i < minutes; i++ {
            value = value - 20 + CGFloat(arc4random_uniform(41))
            if value < 200 { value = 200 }
            if value > 300 { value = 300 }
            valuesPerMinute.append(value)
        }
        self.initLineChart(self.NO2LineChart, valuesPerMinute: valuesPerMinute)

        valuesPerMinute = []
        for var i = 0; i < minutes; i++ { valuesPerMinute.append(500) }
        self.NO2LineChart.color = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        self.NO2LineChart.setChartData(valuesPerMinute)

        valuesPerMinute = []
        value = CGFloat(47)
        for var i = 0; i < minutes; i++ {
            value = value - 2 + CGFloat(arc4random_uniform(5))
            if value < 30 { value = 30 }
            if value > 60 { value = 60 }
            valuesPerMinute.append(value)
        }
        self.initLineChart(self.O3LineChart, valuesPerMinute: valuesPerMinute)

        valuesPerMinute = []
        for var i = 0; i < minutes; i++ { valuesPerMinute.append(100) }
        self.O3LineChart.color = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        self.O3LineChart.setChartData(valuesPerMinute)
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
     * initialize line chart
     * @param lineChart line chart
     * @param valuesPerMinute y values of the chart
     **/
    private func initLineChart(lineChart: FSLineChart, valuesPerMinute: [CGFloat]) {
        let timestamp = passes.first!.timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"

        lineChart.verticalGridStep = 5
        lineChart.horizontalGridStep = 5
        lineChart.labelForIndex = { (item) in
            //return "\(item)"
            return dateFormatter.stringFromDate(timestamp.air_minutesAgo(minutes: -Int(item))!)
        }
        lineChart.labelForValue = { (value) in
            return "\(value)"
        }
        lineChart.fillColor = UIColor.clearColor()
        lineChart.lineWidth = 2
        lineChart.setChartData(valuesPerMinute)
    }

}
