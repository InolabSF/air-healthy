import UIKit


/// MARK: - AIRChemicalGraphTableViewcell
class AIRChemicalGraphTableViewcell: AIRTableViewCell {

    /// MARK: - property

    @IBOutlet weak var chemicalLabel: UILabel!
    @IBOutlet weak var chemicalView: UIView!
    @IBOutlet weak var piechartView: VBPieChart!


    /// MARK: - class method

    /**
     * return cell's height
     * @return cell's height
     **/
    override class func air_height() -> CGFloat {
        return 160.0
    }

    /**
     * get cell
     * @return AIRChemicalGraphTableViewcell
     **/
    class func air_cell() -> AIRChemicalGraphTableViewcell {
        return UINib(nibName: AIRNSStringFromClass(AIRChemicalGraphTableViewcell), bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AIRChemicalGraphTableViewcell
    }

    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        //
        self.piechartView.layer.cornerRadius = self.piechartView.frame.size.width / 2.0
        self.piechartView.layer.masksToBounds = true
        self.piechartView.clipsToBounds = true
        //
        self.chemicalView.layer.shadowOffset = CGSizeMake(0, 0)
        self.chemicalView.layer.shadowOpacity = 0.15
        self.chemicalView.layer.shadowRadius = 2.0
        self.chemicalView.layer.shadowPath = UIBezierPath(roundedRect: self.chemicalView.bounds, cornerRadius: self.chemicalView.bounds.width/2.0).CGPath
    }


    /// MARK: - public api

    /**
     * set color
     * @param color UIColor
     **/
    func setContentViewColor(color: UIColor) {
        self.contentView.backgroundColor = color
    }

    /**
     * set datas
     * @param chemical String
     * @param airHealth [Double]
     * @param animated Bool
     **/
    func setPieChart(chemical chemical: String, airHealth: [Double], animated: Bool) {
        self.chemicalLabel.text = chemical
        self.piechartView.setPieChart(airHealth: airHealth, animated: animated)
/*
        // pie chart
        self.piechartView.enableStrokeColor = true
        self.piechartView.holeRadiusPrecent = 0.5
        self.piechartView.labelsPosition = VBLabelsPosition.OnChart
        self.piechartView.startAngle = Float(M_PI / 2.0 * 3.0)

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
        self.piechartView.setChartValues(
            values,
            animation: animated,
            duration: 0.8,
            options: [.FanAll, .TimingEaseIn]
        )
*/
    }

}
