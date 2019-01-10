//
//  AppDelegate.swift
//  DietLens
//
//  Created by next on 23/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//                         _0_
//                       _oo0oo_
//                      o8888888o
//                      88" . "88
//                      (| -_- |)
//                      0\  =  /0
//                    ___/`---'\___
//                  .' \\|     |// '.
//                 / \\|||  :  |||// \
//                / _||||| -:- |||||- \
//               |   | \\\  -  /// |   |
//               | \_|  ''\---/''  |_/ |
//               \  .-\__  '-'  ___/-. /
//             ___'. .'  /--.--\  `. .'___
//          ."" '<  `.___\_<|>_/___.' >' "".
//         | | :  `- \`.;`\ _ /`;.`/ - ` : | |
//         \  \ `_.   \_ __\ /__ _/   .-` /  /
//     =====`-.____`.___ \_____/___.-`___.-'=====
//                       `=---='
//*****************************************************
//     ¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥
//         €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
//               $$$$$$$$$$$$$$$$$$$$$$$
//                   BUDDHA_BLESS_YOU
//                      AWAY_FROM
//                         BUG

import UIKit
import CoreData
import UserNotifications
import Firebase
import Fabric
import Crashlytics
import HealthKit
import FBSDKCoreKit
import Photos
import FacebookLogin
import GoogleSignIn
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    var isInSignOutProcess: Bool = false
    //location manager
    let locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0
    //global trigger flag
    var isImageCaptureTriggered = false
    var isTextInputTriggered = false
    var isSearchMoreTriggered = false
    //reachability
    let reachability = Reachability()!
    var connectionStatus: Reachability.Connection?
    var noInternetNotifyView =  UIView()
    var fullScreenLoadingView = UIView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        //facebook login init
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //google login init
        GIDSignIn.sharedInstance().clientID = "630060012887-35rcjh6fgh3ehe39me2va3epmg7sg5dd.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        //fabric crashlytic
        Fabric.with([Crashlytics.self])
        CustomPhotoAlbum.init()
        Messaging.messaging().delegate = self as MessagingDelegate
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        registerForPushNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(signOut), name: .signOutErrFlag, object: nil)
        //reachability notifier
        noInternetNotifyView = self.noInternetConnectionView(window: self.window!)
        fullScreenLoadingView = self.initLoadingDialog(window: self.window!)
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.noInternetNotifyView.removeFromSuperview()
            }
            if reachability.connection != self.connectionStatus {
                self.connectionStatus = reachability.connection
                if reachability.connection == .wifi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }

        }
        reachability.whenUnreachable = { reachability in
            //global popView for notify user no Internet Connection
            if reachability.connection != self.connectionStatus {
                self.connectionStatus = reachability.connection
                DispatchQueue.main.async {
                    self.noInternetNotifyView.removeFromSuperview()
                    self.window?.addSubview(self.noInternetNotifyView)
                    self.window?.bringSubview(toFront: self.noInternetNotifyView)
                }
                print("Not reachable")
            }
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        return true
    }

    @objc func signOut() {
    }

    //No internet banner Initlization
    func noInternetConnectionView(window: UIWindow) -> UIView {
        let size = CGSize(width: (self.window?.frame.width)!, height: 60)
        let containerView = PassThroughView(frame: CGRect(origin: CGPoint(x: 0, y: 90), size: size))
        containerView.backgroundColor = UIColor.red
        containerView.alpha = 0.7
        //warning Icon and label
        let warningIcon = UIImageView(frame: CGRect(origin: CGPoint(x: 10, y: 15), size: CGSize(width: 30, height: 30)))
        warningIcon.tintColor = UIColor.white
        warningIcon.image = UIImage(imageLiteralResourceName: "About")
        let warningLabel = UILabel(frame: CGRect(origin: CGPoint(x: 50, y: 20), size: CGSize(width: 300, height: 20)))
        warningLabel.text = "No Internet Connection"
        warningLabel.textColor = UIColor.white
        //dismiss button
        let dismissBtn = UIButton(frame: CGRect(origin: CGPoint(x: (self.window?.frame.width)! - 50, y: 15), size: CGSize(width: 40, height: 40)))
        dismissBtn.setImage(UIImage(imageLiteralResourceName: "whiteCross"), for: .normal)
        dismissBtn.addTarget(self, action: #selector(dismissNoInternetView), for: .touchUpInside)
        containerView.addSubview(warningIcon)
        containerView.addSubview(warningLabel)
        containerView.addSubview(dismissBtn)
        return containerView
    }

    //Loading dialog Initlization
    func initLoadingDialog(window: UIWindow) -> UIView {
        guard let screenWidth = self.window?.frame.width else {
            return UIView()
        }
        guard let screenHeight = self.window?.frame.height else {
            return UIView()
        }
        let dialogWidth = 240
        let dialogHeight = 100
        let size = CGSize(width: dialogWidth, height: dialogHeight)
        //full screen background container
        let backgroundContainer = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        backgroundContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        //dialog container view
        let containerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        containerView.center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 10
        //spinner view
        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinnerIndicator.center = CGPoint(x: dialogWidth/2, y: dialogHeight/2 - 15)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        //loading label
        let loadingTextLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 20)))
        loadingTextLabel.center = CGPoint(x: dialogWidth/2, y: dialogHeight/2 + 15)
        loadingTextLabel.textAlignment = .center
        loadingTextLabel.text = "Loading..."
        loadingTextLabel.textColor = UIColor.black
        //add subView part
        containerView.addSubview(spinnerIndicator)
        containerView.addSubview(loadingTextLabel)
        backgroundContainer.addSubview(containerView)
        return backgroundContainer
    }

    func showLoadingDialog() {
        self.window?.addSubview(fullScreenLoadingView)
    }

    func dismissLoadingDialog() {
        fullScreenLoadingView.removeFromSuperview()
    }

    @objc func dismissNoInternetView() {
        self.noInternetNotifyView.removeFromSuperview()
    }

    func clearPersonalData() {
        let preferences = UserDefaults.standard
        preferences.setValue(nil, forKey: PreferenceKey.userIdkey)
        preferences.setValue(nil, forKey: PreferenceKey.facebookId)
        preferences.setValue(nil, forKey: PreferenceKey.tokenKey)
        preferences.setValue(nil, forKey: PreferenceKey.nickNameKey)
        preferences.setValue(nil, forKey: PreferenceKey.googleUserId)
        preferences.setValue(nil, forKey: PreferenceKey.googleImageUrl)
        //facebook login
//        LoginManager().logOut()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        let appId = FBSDKSettings.appID
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId)") && url.host ==  "authorize" { // facebook
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        } else {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
//            return GIDSignIn.sharedInstance().handle(url as URL?,
//                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
//                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Analytics.logEvent(StringConstants.FireBaseAnalytic.Quit, parameters: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Analytics.logEvent(StringConstants.FireBaseAnalytic.Resume, parameters: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        //upload user step to backend
        uploadStepDataWhenNecessary()
        //get location
        enableLocationServices()
    }

    func enableLocationServices() {
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            break
        case .authorizedWhenInUse:
            // Enable basic location features
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            break
        }
    }

    //judege whether should upload step data to backend
    func uploadStepDataWhenNecessary() {
        let preferences = UserDefaults.standard
        guard let stepUploadLatestTime = preferences.object(forKey: PreferenceKey.stepUploadLatestTime) as? Date else {
            //no record so direct upload
            requestHourlyStepData()
            return
        }
        if Calendar.current.compare(stepUploadLatestTime, to: Date(), toGranularity: .day) == .orderedAscending {
            //request step data & check sahredPreference then send to server
            requestHourlyStepData()
        }
    }
    //request today's data hourly
    func requestHourlyStepData() {
        //request step data & check sahredPreference then send to server
        HKHealthStore().getHourlyStepsCountList { (steps, error) in
            if error == nil {
                //upload stepValue to server
                APIService.instance.uploadStepData(stepList: steps, completion: { (isSuccess) in
                    if isSuccess {
                        //record current date
                        let preferences = UserDefaults.standard
                        preferences.setValue(Date(), forKey: PreferenceKey.stepUploadLatestTime)
                    }
                })
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DietLens")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, _) in
            print("Permission granted: \(granted)")

            guard granted else { return }
            self.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? String {
                    //Do stuff
                    let messageDict: [String: String] = ["message": message]
                    NotificationCenter.default.post(name: .didReceiveNotification, object: nil, userInfo: messageDict)
                }
            } else if let alert = aps["alert"] as? String {
                let messageDict: [String: String] = ["message": alert]
                NotificationCenter.default.post(name: .didReceiveNotification, object: nil, userInfo: messageDict)
                //Do stuff
            }
        }
        // Change this to your preferred presentation option
        completionHandler([])
        //foreGround, notify user to update the list
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? String {
                    //TODO notify foodDiary part to update
                    let messageDict: [String: String] = ["message": message]
                    NotificationCenter.default.post(name: .didReceiveNotification, object: nil, userInfo: messageDict)
                }
            } else if let alert = aps["alert"] as? String {
                //TODO notify foodDiary part to update
                let messageDict: [String: String] = ["message": alert]
                NotificationCenter.default.post(name: .didReceiveNotification, object: nil, userInfo: messageDict)
            }
            if let notificationId = userInfo["gcm.notification.id"] as? String {
                //jump to notification detail page with notificationID
                print("Notification ID: \(notificationId)")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let viewController = storyboard.instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController else {
                    return
                }
                window?.rootViewController = viewController
                if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "notificationDetailVC") as?  NotificationDetailViewController {
                    dest.notificationId = notificationId
                    window?.rootViewController?.present(dest, animated: true, completion: nil)
                }

            }
        }
        // Print full message
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        let preferences = UserDefaults.standard
        let userId = preferences.string(forKey: PreferenceKey.userIdkey)
        if userId != nil {
             //send token to server
            APIService.instance.saveDeviceToken(uuid: userId!, fcmToken: fcmToken, status: true, completion: { (flag) in
                if flag {
                    print("send device token succeed")
                }
            })
        } else {
            //restore fcm token waitting for Login/Register to upload token
            preferences.setValue(fcmToken, forKey: PreferenceKey.fcmTokenKey)
        }
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

extension AppDelegate: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            let userId = user.userID
        }

    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //perform disconnect code
    }

}

extension AppDelegate: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = (locations.last?.coordinate.latitude)!
        self.longitude = (locations.last?.coordinate.longitude)!
        print("latitude:\(latitude)")
        print("longitude:\(longitude)")
        locationManager.stopUpdatingLocation()
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UINavigationController {
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
