import UIKit


/// MARK: - AIRGraphViewController
class AIRGraphViewController: UIViewController {

    /// MARK: - property
    @IBOutlet weak var pieChartView: VBPieChart!


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pieChartView.enableStrokeColor = true
        self.pieChartView.holeRadiusPrecent = 0.5
        self.pieChartView.labelsPosition = VBLabelsPosition.OnChart
        self.pieChartView.startAngle = Float(M_PI / 2.0 * 3.0)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.pieChartView.setChartValues(
            [
                ["name" : "NO2", "value" : NSNumber(int: 60), "color" : UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)],
                ["name" : "", "value" : NSNumber(int: 40), "color" : UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 0.0)],
            ],
            animation: true,
            duration: 0.8,
            options: [.FanAll, .TimingEaseIn]
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
