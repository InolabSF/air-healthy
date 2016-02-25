///// MARK: - AIRUserMarker
//class AIRUserMarker: GMSMarker {
//
//    /// MARK: - property
//
//    var user: AIRUser!
//
//
//    /// MARK: - initialization
//
//    init(user: AIRUser) {
//        super.init()
//
//        self.user = user
//
//        var status = "good"
//        if user.air < 1 { status = "good" }
//        else if user.air < 2 { status = "normal" }
//        else { status = "bad" }
//
//        self.icon = UIImage(named: "marker_user_\(status)")
//        self.position = user.location.coordinate
//        self.appearAnimation = kGMSMarkerAnimationPop
//
//        let dateFormatter = NSDateFormatter.air_dateFormatter()
//        dateFormatter.dateFormat = "MM/dd HH:mm"
//        let dateString = dateFormatter.stringFromDate(user.timestamp)
//        self.title = "\(dateString)"
//
//        self.snippet = "\(user.name): \(status)"
//
//    }
//
//
//    /// MARK: - public api
//
//}
