import CoreLocation


/// MARK: - LOG

/**
 * display log
 * @param body log
 */
func AIRLOG(str: String) {
#if DEBUG
    print(str)
#endif
}


/// MARK: - function

/**
 * return class name
 * @param classType classType
 * @return class name
 */
func AIRNSStringFromClass(classType:AnyClass) -> String {
    let classString = NSStringFromClass(classType.self)
    let range = classString.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: Range<String.Index>(start:classString.startIndex, end: classString.endIndex), locale: nil)
    return classString.substringFromIndex(range!.endIndex)
}


/// MARK: - Location

struct AIRLocation {
    /// seconds to update location
    static let IntervalToStartUpdatingLocation = 3.0

    /// distance to update location
    static let DistanceToUpdateLocation: CLLocationDistance = 20.0

    /// comfirming count to update location
    static let ComfirmingCountToUpdateLocation = 3
}

/// MARK: - Google Map

/// Base URI
let kURIGoogleMapAPI =                  "https://maps.googleapis.com/maps/api"

struct AIRGoogleMap {

    /// API key
    static let APIKey =                 kAIRGoogleMapAPIKey
    static let BrowserAPIKey =          kAIRGoogleMapBrowserAPIKey

    /// MARK: - API
    struct API {
        static let GeoCode =           kURIGoogleMapAPI + "/geocode/json" /// geocode API
        static let PlaceNearBySearch = kURIGoogleMapAPI + "/place/nearbysearch/json" // place nearbysearch API
    }

    /// MARK: - status code
    static let Status =                     "status"
    struct Statuses {
        static let OK =                     "OK"
        static let NotFound =               "NOT_FOUND"
        static let ZeroResults =            "ZERO_RESULTS"
        static let MaxWayPointsExceeded =   "MAX_WAYPOINTS_EXCEEDED"
        static let InvalidRequest =         "INVALID_REQUEST"
        static let OverQueryLimit =         "OVER_QUERY_LIMIT"
        static let RequestDenied =          "REQUEST_DENIED"
        static let UnknownError =           "UNKNOWN_ERROR"
    }

}
