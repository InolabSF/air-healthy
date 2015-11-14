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
        return 72.0
    }


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener


    /// MARK: - public api

    /**
     * set datas
     * @param location AIRLocation
     **/
    func set(location location: AIRLocation) {
        self.locationLabel.text = "Place in Parkside"
    }

}
