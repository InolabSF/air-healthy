///// MARK: - AIRUser
//class AIRUser {
//
//    /// MARK: - property
//    var userID = 0
//    var air = 0
//    var location = CLLocation(latitude: 0.0, longitude: 0.0)
//    var uuid = ""
//    var name = ""
//    var timestamp = NSDate()
//
//
//    /// MARK: - class method
//
//    /**
//     * users from JSON
//     * @param json JSON
//     * @return [AIRUser]
//     **/
//    class func users(json json: JSON) -> [AIRUser] {
//        var users: [AIRUser] = []
//        if json["application_code"].intValue != 200 { return users }
//
//        let myUUID = NSUserDefaults().stringForKey(AIRUserDefaults.UUID)
//
//        let dateFormatter = NSDateFormatter.air_dateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//        dateFormatter.timeZone = NSTimeZone(name: "UTC")
//
//        let JSONs = json["users"].arrayValue
//        for j in JSONs {
//            let uuid = j["uuid"].stringValue
//            if myUUID == uuid { continue }
//
//            let user = AIRUser()
//            user.userID = j["id"].intValue
//            user.air = j["air"].intValue
//            user.location = CLLocation(latitude: j["lat"].doubleValue, longitude: j["lng"].doubleValue)
//            user.uuid = uuid
//            user.name = j["name"].stringValue
//
//            let timestamp = dateFormatter.dateFromString(j["timestamp"].stringValue)
//            if timestamp == nil { continue }
//            user.timestamp = timestamp!
//
//            users.append(user)
//        }
//
//        return users
//    }
//
//}
