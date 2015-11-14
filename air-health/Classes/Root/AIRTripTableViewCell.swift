import UIKit
import CoreLocation


/// MARK: - AIRTripTableViewCell
class AIRTripTableViewCell: AIRTableViewCell {

    /// MARK: - property
    @IBOutlet weak var tripLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!


    /// MARK: - class method

    /**
     * return cell's height
     * @return cell's height
     **/
    override class func air_height() -> CGFloat {
        return 64.0
    }


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener


    /// MARK: - public api

    /**
     * set datas
     * @param start start location
     * @param end end location
     **/
    func set(start start: CLLocation, end: CLLocation) {
        var min = Int(end.timestamp.timeIntervalSinceDate(start.timestamp) / 60)
        let hour = min / 60
        if hour > 0 {
            min -= hour * 60
            self.tripLabel.text = "\(hour) hour \(min) min"
        }
        else { self.tripLabel.text = "\(min) min" }

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.startTimeLabel.text = dateFormatter.stringFromDate(start.timestamp)
        self.endTimeLabel.text = dateFormatter.stringFromDate(end.timestamp)
    }

}
