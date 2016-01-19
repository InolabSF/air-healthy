import Foundation


/// MARK: - NSDateFormatter+USStyle
extension NSDateFormatter {

    /// MARK: - class method

    /**
     * get US Style dateformatter
     * @return NSAttributedString
     **/
    class func air_dateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
            // locale
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            // calendar
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .FullStyle
        return dateFormatter
    }

}
