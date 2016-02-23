import CoreLocation


/// MARK: - LOG

/**
 * display log
 * @param body log
 */
func AIRLOG(body: Any) {
#if DEBUG
    print(body)
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

/**
 * return class name
 * @param classType classType
 * @return class name
 */
func AIRNSStringFromClassString(classString: String) -> String {
    let range = classString.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: Range<String.Index>(start:classString.startIndex, end: classString.endIndex), locale: nil)
    return classString.substringFromIndex(range!.endIndex)
}


/// MARK: - User Defaults

struct AIRUserDefaults {
    static let DemoCSV =            "AIRUserDefaults.DemoCSV_0.1.0_1.0.2"
    static let UUID =               "AIRUserDefaults.UUID"

    static let SensorDate =         "AIRUserDefaults.SensorDate"
    static let GPSIsOff =           "AIRUserDefaults.GPSIsOff"

    static let UserDate =           "AIRUserDefaults.UserDate"
    static let UserIsOn =           "AIRUserDefaults.UserIsOn"

    static let Tutorial =           "AIRUserDefaults.Tutorial"
}


/// MARK: - NotificationCenter
struct AIRNotificationCenter {
    static let UpdateSensorValues =       "AIRNotificationCenter.UpdateSensorValues"
    static let DidUpdateSensorValues =    "AIRNotificationCenter.DidUpdateSensorValues"
    static let DidUpdateMapSensors =      "AIRNotificationCenter.DidUpdateMapSensors"
    static let UpdateLocation =           "AIRNotificationCenter.UpdateLocation"
    static let LaunchFromBadAirWarning =  "AIRNotificationCenter.LaunchFromBadAirWarning"
    static let TutorialMoveSlide =        "AIRNotificationCenter.TutorialMoveSlide"
    static let TutorialChangeSlide =      "AIRNotificationCenter.TutorialChangeSlide"
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

    /// zoom
    struct Zoom {
        static let Default: Float =        13.0
        static let Min: Float =            4.0
        static let Max: Float =            15.0
    }

}


/// MARK: - Parse

struct AIRParse {

    /// API key
    static let ApplicationID =                 kAIRParseApplicationID
    static let ClientKey =                     kAIRParseClientKey
}


/// MARK: - Vasp

/// Base URI
#if LOCAL
let kURIVaspAPI =                  "http://localhost:3000"
#else
let kURIVaspAPI =                  "https://vasp.herokuapp.com"
#endif

struct AIRVasp {

    /// MARK: - API
    struct API {
        static let Square =           kURIVaspAPI + "/square" /// square API
    }
}
