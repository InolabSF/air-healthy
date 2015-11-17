import UIKit


/// MARK: - AIRLocationTableViewCell
class AIRLocationTableViewCell: AIRTableViewCell {

    /// MARK: - property
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!


    /// MARK: - class method

    /**
     * return cell's height
     * @return cell's height
     **/
    override class func air_height() -> CGFloat {
        return 93.0
    }


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener


    /// MARK: - public api

    /**
     * set datas
     * @param location CLLocation
     **/
    func set(location location: CLLocation) {
        //self.locationLabel.text = "Place in Parkside"
        self.locationLabel.text = "\(location)"
    }

}
