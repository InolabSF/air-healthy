import UIKit


/// MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// MARK: - property
    var window: UIWindow?


    /// MARK: - life cycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey(AIRGoogleMap.APIKey)

        // demo csv
        let doesLoadDemoCSV = NSUserDefaults().boolForKey(AIRUserDefaults.DemoCSV)
        if !doesLoadDemoCSV {
            let path = NSBundle.mainBundle().pathForResource("ZAIRLOCATION", ofType: "csv")!
            var error: NSErrorPointer = nil
            if let csv = CSV(contentsOfFile: path, error: error) {
                var locations: [CLLocation] = []

                let rows = csv.rows
                for var i = 0; i < rows.count; i++ {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

                    let location = CLLocation(
                        coordinate: CLLocationCoordinate2D(latitude: Double(rows[i]["lat"]!)!, longitude: Double(rows[i]["lng"]!)!),
                        altitude: Double(rows[i]["altitude"]!)!,
                        horizontalAccuracy: Double(rows[i]["hAccuracy"]!)!,
                        verticalAccuracy: Double(rows[i]["vAccuracy"]!)!,
                        course: Double(rows[i]["course"]!)!,
                        speed: Double(rows[i]["speed"]!)!,
                        timestamp: dateFormatter.dateFromString(rows[i]["timestamp"]!)!.air_daysAgo(days: -1)!
                    )
                    locations.append(location)
                }
                AIRLocation.save(locations: locations)

                NSUserDefaults().setObject(true, forKey: AIRUserDefaults.DemoCSV)
                NSUserDefaults().synchronize()
            }
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}
