import UIKit


/// MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// MARK: - property
    var window: UIWindow?


    /// MARK: - life cycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey(AIRGoogleMap.APIKey)

        let doesLoadDemoCSV = NSUserDefaults().boolForKey(AIRUserDefaults.DemoCSV)
        if !doesLoadDemoCSV {
            //AIRLocationManager.sharedInstance.saveDemoData()
            AIRSensorManager.sharedInstance.saveDemoData()
            NSUserDefaults().setObject(true, forKey: AIRUserDefaults.DemoCSV)
            NSUserDefaults().synchronize()
        }

        AIRLocationManager.sharedInstance.startUpdatingLocation()

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
