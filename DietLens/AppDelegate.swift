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
import RealmSwift
import Fabric
import Crashlytics
import LGSideMenuController
import HealthKit
import FBSDKCoreKit
import Photos
import FacebookLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    var isInSignOutProcess: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
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
        return true
    }

    @objc func signOut() {
//        APIService.instance.logOut(completion: { (_) in
//            //signOut no matter request succeed or not
//            DispatchQueue.main.async {
//                self.clearPersonalData()
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                if let destController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController {
//                    self.window?.rootViewController?.present(destController, animated: true, completion: nil)
//
//                }
//            }
//        })
    }

    func clearPersonalData() {
        let preferences = UserDefaults.standard
        let nicknameKey = "nickname"
        preferences.setValue(nil, forKey: nicknameKey)
        preferences.setValue(nil, forKey: PreferenceKey.facebookId)
        preferences.setValue(nil, forKey: PreferenceKey.tokenKey)
        preferences.setValue(nil, forKey: PreferenceKey.nickNameKey)
        //facebook login
        LoginManager().logOut()
    }

    func realmSetting(_ application: UIApplication) {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { _, _ in
//                migration.deleteData(forType: FoodDiary.className())
//                migration.deleteData(forType: IngredientDiary.className())
//                migration.deleteData(forType: FoodInfomation.className())
//                migration.deleteData(forType: Portion.className())
//                if oldSchemaVersion <= 1 {
//                    migration.enumerateObjects(ofType: IngredientDiary.className()) { oldObject, newObject in
//                        newObject?["quantity"] = Double(oldObject?["quantity"] as! Int)
//                    }
//                }
//                if oldSchemaVersion <= 2 {
//                    migration.enumerateObjects(ofType: FoodDiary.className()) { _, newObject in
//                        newObject?["quantity"] = 1.0
//                        newObject?["unit"] = "portion"
//                    }
//                }
//                if oldSchemaVersion <= 3 {
//                    migration.enumerateObjects(ofType: FoodDiary.className()) { oldObject, newObject in
////                        let foodInfoList = newObject?.dynamicList("foodInfoList")
//                        let foodInfoList =  newObject?["foodInfoList"] as! List<MigrationObject>
//                        let foodInfo = migration.create(FoodInfomation.className(), value: FoodInfomation())
////                        let foodInfo = MigrationObject()
//                        foodInfo["foodId"] = oldObject?["foodId"]
//                        foodInfo["foodName"] = oldObject?["foodName"]
//                        foodInfo["carbohydrate"] = oldObject?["carbohydrate"]
//                        foodInfo["protein"] = oldObject?["protein"]
//                        foodInfo["fat"] = oldObject?["fat"]
//                        foodInfo["calorie"] = oldObject?["calorie"]
//                        foodInfo["category"] = oldObject?["category"]
//                        foodInfo["sampleImagePath"] = oldObject?["imagePath"]
//                        foodInfoList.append(foodInfo)
//                        //portion part
//                        let portionList = foodInfo["portionList"] as! List<MigrationObject>
//                        let portion = migration.create(Portion.className(), value: Portion())
//                        portion["weightValue"] = 100
//                        portion["sizeUnit"] = oldObject?["unit"]
//                        portionList.append(portion)
//                        //changing part
//                        newObject?["quantity"] = 1
//                        newObject?["selectedFoodInfoPos"] = 0
//                        newObject?["selectedPortionPos"] = 0
//                    }
//                }

        })
        Realm.Configuration.defaultConfiguration = config
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //upload user step to backend
        FBSDKAppEvents.activateApp()
        uploadStepDataWhenNecessary()
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
                guard let viewController = storyboard.instantiateViewController(withIdentifier: "sideLGMenuVC") as? LGSideMenuController else {
                    return
                }
                window?.rootViewController = viewController
                if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "notificationDetailVC") as?  NotificationDetailViewController {
                    dest.notificationId = notificationId
                    window?.rootViewController?.sideMenuController?.rootViewController?.present(dest, animated: true, completion: nil)
                }
                //to notification detail
//                if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "notificationListVC") as?  NotificationsViewController {
//                    window?.rootViewController?.sideMenuController?.rootViewController?.present(dest, animated: true, completion: nil)
//                }

            }
        }
        // Print full message
        completionHandler()
        //open the notification page from the background

//        let viewController = self.window!.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "DietLens") as! HomeViewController

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
