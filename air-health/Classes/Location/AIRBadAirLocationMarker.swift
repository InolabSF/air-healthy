import Social


/// MARK: - AIRShareMarker
class AIRBadAirLocationMarker: GMSMarker {

    /// MARK: - property

    var location: CLLocation!
    var parentViewController: UIViewController?


    /// MARK: - initialization

    init(location: CLLocation) {
        super.init()
/*
        self.icon = IonIcons.imageWithIcon(
            ion_share,
            iconColor: UIColor(red: 142.0/255.0, green: 68.0/255.0, blue: 173.0/255.0, alpha: 1.0),
            iconSize: 32,
            imageSize: CGSizeMake(32, 32)
        )
*/
        self.icon = UIImage(named: "home_mask_marker")
        self.position = location.coordinate
        self.location = location
    }


    /// MARK: - public api

    /**
     * share bad air on social
     * @param parentView UIView
     **/
    func shareSocial(parentViewController parentViewController: UIViewController) {
        let actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.title = "Share Bad Air on Social Network"
        actionSheet.addButtonWithTitle("Twitter")
        actionSheet.addButtonWithTitle("Facebook")
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = 2
        self.parentViewController = parentViewController
        actionSheet.showInView(self.parentViewController!.view)
    }

}


/// MARK: - UIActionSheetDelegate
extension AIRBadAirLocationMarker: UIActionSheetDelegate {

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var serviceType: String? = nil
        if buttonIndex == 0 { serviceType = SLServiceTypeTwitter }
        else if buttonIndex == 1 { serviceType = SLServiceTypeFacebook }
        if serviceType == nil { return }

        if self.parentViewController == nil { return }

        if !SLComposeViewController.isAvailableForServiceType(serviceType!) { return }

        let name = AIRLocationName.fetch(location: location)
        if name == nil { return }
        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.stringFromDate(self.location.timestamp)

        let vc = SLComposeViewController(forServiceType: serviceType!)
        vc.setInitialText("BAD AIR WARNING!\n\(name!.name) \(time)")

/*
        let uri = NSURL(
            URLString: "https://www.google.com/maps/place/\(location.coordinate.latitude)+\(location.coordinate.longitude)/@\(location.coordinate.latitude),\(location.coordinate.longitude),16z",
            queries: ["q":name!.name]
        )
        vc.addURL(uri)
*/
        let uri = NSURL(
            URLString: "https://maps.googleapis.com/maps/api/staticmap",
            queries: [
                "zoom" : "16",
                "scale" : "false",
                "size" : "960x960",
                "maptype" : "roadmap",
                "format" : "png",
                "visual_refresh" : "true",
                "center" : "\(location.coordinate.latitude),\(location.coordinate.longitude)",
                "markers" : "icon:\("http://dl.dropboxusercontent.com/u/30701586/images/air-health/marker_mask.png")|\(location.coordinate.latitude),\(location.coordinate.longitude)",
            ]
        )
        vc.addImage(UIImage(data: NSData(contentsOfURL: uri!)!))
        vc.completionHandler = { (result: SLComposeViewControllerResult) -> Void in
        }
        self.parentViewController!.presentViewController(vc, animated: true, completion: nil)
    }
}
