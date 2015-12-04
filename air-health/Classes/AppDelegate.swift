import UIKit


/// MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// MARK: - property
    var window: UIWindow?


    /// MARK: - life cycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // google maps
        GMSServices.provideAPIKey(AIRGoogleMap.APIKey)

        // parse
        Parse.setApplicationId(AIRParse.ApplicationID, clientKey: AIRParse.ClientKey)
        PFUser.enableAutomaticUser()
        PFACL.setDefaultACL(PFACL(), withAccessForCurrentUser: true)

/*
        let doesLoadDemoCSV = NSUserDefaults().boolForKey(AIRUserDefaults.DemoCSV)
        if !doesLoadDemoCSV {
            AIRLocationManager.sharedInstance.saveDemoData()
            AIRSensorManager.sharedInstance.saveDemoData()
            NSUserDefaults().setObject(true, forKey: AIRUserDefaults.DemoCSV)
            NSUserDefaults().synchronize()
        }
*/

        AIRLocationManager.sharedInstance.startUpdatingLocation()

//        AIRLOG(AIRSensor.convertOzone_S(value: 508.0, temperature: 18.0))
//        AIRLOG(AIRSensor.convertSO2(value: 548.0, temperature: 18.0))

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // notification
        NSNotificationCenter.defaultCenter().postNotificationName(
            AIRNotificationCenter.UpdateSensorValues,
            object: nil,
            userInfo: [:]
        )
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}
