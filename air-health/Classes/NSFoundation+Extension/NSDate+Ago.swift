import Foundation


/// MARK: - NSURL+Ago
extension NSDate {

    /// MARK: - class method

    /**
     * get date from Int
     * @param year Int
     * @param month Int
     * @param day Int
     * @return NSDate?
     **/
    class func air_date(year year: Int, month: Int, day: Int) -> NSDate? {
        let dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.dateFromComponents(dateComponents)
    }


    /// MARK: - public api

    /**
     * get the Date ~ months ago
     * @param months months
     * @return NSDate
     */
    func air_monthAgo(months months: Int) -> NSDate? {
        let dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.month = -months
        return calendar.dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions(rawValue: 0))
    }

    /**
     * get the Date ~ days ago
     * @param days days
     * @return NSDate
     */
    func air_daysAgo(days days: Int) -> NSDate? {
        let dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.day = -days
        return calendar.dateByAddingComponents(dateComponents, toDate: self, options: [])
    }

    /**
     * get the Date ~ hours ago
     * @param hours hours
     * @return NSDate
     */
    func air_hoursAgo(hours hours: Int) -> NSDate? {
        let dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.hour = -hours
        return calendar.dateByAddingComponents(dateComponents, toDate: self, options: [])
    }

    /**
     * get the Date ~ minutes ago
     * @param minutes minutes
     * @return NSDate
     */
    func air_minutesAgo(minutes minutes: Int) -> NSDate? {
        let dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.minute = -minutes
        return calendar.dateByAddingComponents(dateComponents, toDate: self, options: [])
    }

}
