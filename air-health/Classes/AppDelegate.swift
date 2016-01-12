import UIKit
import Fabric
import Crashlytics


/// MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// MARK: - property
    var window: UIWindow?


    /// MARK: - life cycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Crashlytics
        Fabric.with([Crashlytics.self])
        // google maps
        GMSServices.provideAPIKey(AIRGoogleMap.APIKey)
/*
        // parse
        Parse.setApplicationId(AIRParse.ApplicationID, clientKey: AIRParse.ClientKey)
        PFUser.enableAutomaticUser()
        PFACL.setDefaultACL(PFACL(), withAccessForCurrentUser: true)
*/
        // UUID
        var UUID = NSUserDefaults().stringForKey(AIRUserDefaults.UUID)
        if UUID == nil {
            UUID = NSUUID().UUIDString
            NSUserDefaults().setObject(UUID!, forKey: AIRUserDefaults.UUID)
            NSUserDefaults().synchronize()
        }
/*
        let doesLoadDemoCSV = NSUserDefaults().boolForKey(AIRUserDefaults.DemoCSV)
        if !doesLoadDemoCSV {
            AIRLocationManager.sharedInstance.saveDemoData()
            AIRSensorManager.sharedInstance.saveDemoData()
            NSUserDefaults().setObject(true, forKey: AIRUserDefaults.DemoCSV)
            NSUserDefaults().synchronize()
        }
*/

        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert,], categories: nil))
        if launchOptions != nil && launchOptions![UIApplicationLaunchOptionsLocalNotificationKey] != nil {
            dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)),
                dispatch_get_main_queue(),
                { () in
                    // notification
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        AIRNotificationCenter.LaunchFromBadAirWarning,
                        object: nil,
                        userInfo: [:]
                    )
                }
            )
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
        // notification
        NSNotificationCenter.defaultCenter().postNotificationName(
            AIRNotificationCenter.UpdateSensorValues,
            object: nil,
            userInfo: [:]
        )
    }

    func applicationWillTerminate(application: UIApplication) {
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if application.applicationState == .Inactive {
            // notification
            NSNotificationCenter.defaultCenter().postNotificationName(
                AIRNotificationCenter.LaunchFromBadAirWarning,
                object: nil,
                userInfo: [:]
            )
        }
    }

}
