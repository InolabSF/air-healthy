import UIKit


/// MARK: - AIRLineGraphTableViewcell
class AIRLineGraphTableViewCell: UITableViewCell {

    /// MARK: - property

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var lineGraph: FSLineChart!


    /// MARK: - class method

    /**
     * return cell's height
     * @return cell's height
     **/
    class func air_height() -> CGFloat {
        return 256.0
    }


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener


    /// MARK: - public api

    /**
     * set datas
     * @param title graph title
     * @param graphDatas [CGFloat]
     **/
    func set(title title: String, graphDatas: [CGFloat]) {
        // title
        self.titleLabel.text = title

        // graph
        self.lineGraph.verticalGridStep = 5
        self.lineGraph.horizontalGridStep = 9
        self.lineGraph.labelForIndex = { (item) in
            return "\(item)"
        }
        self.lineGraph.labelForValue = { (value) in
            return "\(value)"
        }
        self.lineGraph.setChartData(graphDatas)
    }

}
