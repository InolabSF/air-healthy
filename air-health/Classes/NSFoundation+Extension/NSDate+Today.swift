import Foundation


/// MARK: - NSURL+Today
extension NSDate {

    /// MARK: - class method


    /// MARK: - public api

    /**
     * isToday
     * @return Bool
     */
    func air_isToday() -> Bool {
        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return (dateFormatter.stringFromDate(self) == dateFormatter.stringFromDate(NSDate()))
    }


}
