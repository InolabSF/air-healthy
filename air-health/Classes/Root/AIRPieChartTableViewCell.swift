import UIKit


/// MARK: - AIRPieChartTableViewCell
class AIRPieChartTableViewCell: AIRTableViewCell {

    /// MARK: - property
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var airHealthPercentageLabel: UILabel!
    @IBOutlet weak var pieChartView: VBPieChart!


    /// MARK: - class method

    /**
     * return cell's height
     * @return cell's height
     **/
    override class func air_height() -> CGFloat {
        return 360.0
    }


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener


    /// MARK: - public api

    /**
     * set datas
     * @param day String
     * @param airHealth Double
     * @param animated Bool
     **/
    func set(day day: String, airHealth: Double, animated: Bool) {
        // day
        self.dayLabel.text = day
        // air health percentage
        self.airHealthPercentageLabel.text = "\(Int(airHealth))%"
        // pie chart
        self.pieChartView.enableStrokeColor = true
        self.pieChartView.holeRadiusPrecent = 0.5
        self.pieChartView.labelsPosition = VBLabelsPosition.OnChart
        self.pieChartView.startAngle = Float(M_PI / 2.0 * 3.0)
        let airUnhealth = 100.0 - airHealth
        self.pieChartView.setChartValues(
            [
                ["name" : "", "value" : NSNumber(double: airHealth), "color" : UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)],
                ["name" : "", "value" : NSNumber(double: airUnhealth), "color" : UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.0)],
            ],
            animation: animated,
            duration: 0.8,
            options: [.FanAll, .TimingEaseIn]
        )

    }


}
