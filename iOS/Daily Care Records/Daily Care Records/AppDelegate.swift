//
//  AppDelegate.swift
//  Medication
//
//  Created by Techwin Labs on 4/4/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import UserNotifications
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, UIGestureRecognizerDelegate {

    var window: UIWindow?
    var viewController = SWRevealViewController()
    var dataConsumptionCount : Int = 0
    var accessTimer = Timer()
    var access = 1
    var gameTimer: Timer!
    var secondTimer:Timer!
    let tapGesture = UITapGestureRecognizer(target: self, action: nil)
    var alert:UIAlertController?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // observer to set home screen
        // initiate fabric
        Fabric.with([Crashlytics.self])
        // permission for push notifications
        UIApplication.shared.applicationIconBadgeNumber = 0
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    // new code for remove error like UIApplication.registerForRemoteNotification () must be used  from main thread only
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                    // UIApplication.shared.registerForRemoteNotifications()
                }
                else{
                    //Do stuff if unsuccessful...
                }
            })
        }
        else
        {
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            
            let setting = UIUserNotificationSettings(types: type, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting);
            UIApplication.shared.registerForRemoteNotifications();
        }
        
        let notificationName = Notification.Name("HomeScreen")
        NotificationCenter.default.addObserver(self, selector: #selector(setHomeScreen), name: notificationName, object: nil)
        let showAppWindow = Notification.Name("ShowAppWindow")
        NotificationCenter.default.addObserver(self, selector: #selector(showAppMainWindow), name: showAppWindow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeTapGesture), name: NSNotification.Name(rawValue: "removeTap"), object: nil)
        // set home screen if logged in
        if let is_login = utilityMgr.getUDVal(forKey: "isLogin") as? Bool {
            if is_login {
                // constantly monitor access
                DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
                    // hit for first time
                    self.get_company_accesses()
                    self.accessTimer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(self.get_company_accesses), userInfo: nil, repeats: true)
                    self.accessTimer.fire()
                })
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeScreen"), object: nil)
            }
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // User tapped on screen, do whatever you want to do here.
        if (gameTimer) != nil{
            gameTimer.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: 290, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
        }else{
            gameTimer = Timer.scheduledTimer(timeInterval: 290, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
        }
        
        return false
    }
    
    func removeTapGesture(){
         NotificationCenter.default.removeObserver("removeTap")
        gameTimer.invalidate()
        if secondTimer != nil{
            secondTimer.invalidate()
        }
        window?.removeGestureRecognizer(tapGesture)
    }
    
    func runTimedCode(){
        if alert != nil{
            self.alert?.dismiss(animated: false, completion: nil)
            self.alert = nil
        }
        secondTimer.invalidate()
//        let alert2 = UIAlertController(title: APPNAME, message: "Session Expired", preferredStyle: .alert)
//        let action = UIAlertAction(title: "OK", style: .default) { (logoutApp) in
            utilityMgr.emptyDefaults()
            NotificationCenter.default.post(name: Notification.Name("ShowAppWindow"), object: nil)
//        }
//        alert2.addAction(action)
//        window?.rootViewController?.present(alert2, animated: true, completion: nil)
    }
    
    func runTimer(){
//        startTimer()
        if self.secondTimer != nil{
            self.secondTimer.invalidate()
        }
        self.gameTimer.invalidate()
        self.secondTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
        
         alert = UIAlertController(title: APPNAME, message: "Do you want more time?", preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (Yes) in
            if self.secondTimer != nil{
                 self.secondTimer.invalidate()
            }
            self.gameTimer.invalidate()
             self.secondTimer = Timer.scheduledTimer(timeInterval: 290, target: self, selector: #selector(self.runTimer), userInfo: nil, repeats: true) //290
        }
        let actionNo = UIAlertAction(title: "No", style: .default) { (No) in
            if self.secondTimer != nil{
                self.secondTimer.invalidate()
            }
            self.gameTimer.invalidate()
            self.secondTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
        }
        alert?.addAction(actionYes)
        alert?.addAction(actionNo)
        window?.rootViewController?.present(alert!, animated: true, completion: nil)
    }
    func startTimer(){
        if self.secondTimer != nil{
            self.gameTimer.invalidate()
            self.secondTimer.invalidate()
            self.secondTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
        }else{
            self.gameTimer.invalidate()
            self.secondTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
        }
    }
    // MARK:- Set home screen
    func setHomeScreen() {
        NotificationCenter.default.removeObserver("HomeScreen")
        tapGesture.delegate = self
        if gameTimer != nil{
            gameTimer.invalidate()
        }
        window?.addGestureRecognizer(tapGesture)
        var mStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let refr = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        if utilityMgr.getUDVal(forKey: "employee_type") as! String == "2" || utilityMgr.getUDVal(forKey: "employee_type") as! String == "3" {
            // Manager
            mStoryboard = UIStoryboard.init(name: "Manager", bundle: Bundle.main)
        }
        var vc = UIViewController()
        if utilityMgr.getUDVal(forKey: "employee_type") as! String == "2" || utilityMgr.getUDVal(forKey: "employee_type") as! String == "3"  {
            // Manager
            vc = mStoryboard.instantiateViewController(withIdentifier: "ManagerHomeVC") as! ManagerHomeVC
        } else {
            vc = mStoryboard.instantiateViewController(withIdentifier: "CarerHomeVC") as! CarerHomeVC
        }
        let sideMenuVC = refr.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
        
        let frontNavVC = UINavigationController.init(rootViewController: vc)
        let rearNavVC = UINavigationController.init(rootViewController: sideMenuVC)
        rearNavVC.navigationBar.isHidden = true
        let revealController : SWRevealViewController = SWRevealViewController.init(rearViewController: rearNavVC, frontViewController: frontNavVC)
        viewController = revealController
        self.window?.rootViewController = viewController
    }
    func showAppMainWindow() {
        accessTimer.invalidate()
        if gameTimer != nil{
            gameTimer.invalidate()
        }
        window?.removeGestureRecognizer(tapGesture)
        let sBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainVC = sBoard.instantiateInitialViewController()
        self.window?.rootViewController = mainVC
    }
    //MARK: - iOS 10 Notifications Methods
//    @available(iOS 10.0, *)
//    private func userNotificationCenter(_ center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
//        //Handle the notification
//         completionHandler([.alert,.badge,.sound])
//    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound,.badge])
    }
    
    @available(iOS 10.0, *)
    private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        //Handle the notification
        // display the userInfo
//        let userinfo = response.notification.request.content.userInfo
    }

    
    //MARK: - iOS 8 onwards Notifications Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenStr = convertDeviceTokenToString(deviceToken: deviceToken)
        print("Device Token.....\(deviceTokenStr)")
//            let alert:UIAlertView = UIAlertView (title: "DEVICE TOKEN", message: deviceTokenStr, delegate: nil, cancelButtonTitle: "Ok")
//            alert.show()
        let defaults = UserDefaults.standard
        defaults.set(deviceTokenStr, forKey: "devicetoken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ", terminator: "")
        print(error.description)
    }
    
    private func convertDeviceTokenToString(deviceToken:NSData) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.replacingOccurrences(of: ">", with: "", options: [], range: nil)
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: "<", with: "", options: [], range: nil)
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: " ", with: "", options: [], range: nil)
        
        // Our API returns token in all uppercase, regardless how it was originally sent.
        // To make the two consistent, I am uppercasing the token string here.
        deviceTokenStr = deviceTokenStr.uppercased()
        return deviceTokenStr
    }
    
    // Called when a notification is received and the app is in the
    // foreground (or if the app was in the background and the user clicks on the notification).
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("without comlitionHandler called")
   
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        CheckSection.checkSectionType(userInfo: userInfo)
        completionHandler(.newData)
    }
    
   
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
                utilityMgr.emptyDefaults()
                NotificationCenter.default.post(name: Notification.Name("ShowAppWindow"), object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        // send data usage when user logged in
        if (utilityMgr.getUDVal(forKey: "isLogin") as? Bool) != nil {
            sendDataUsage()
        }
    }
    // MARK:- Server calls
    private func sendDataUsage(){
        let param = ["data":dataConsumptionCount*10]
        apiMgr.PostApi(param, webserviceURL: UrlConstants.BASE_URL+UrlConstants.insert_dataUsage, success: { (response) in
            print("*data usage sent*")
        }) { (error) in
            // failed to send 
        }
    }
    @objc private func get_company_accesses(){
        DispatchQueue.global(qos: .background).async {
            let link = UrlConstants.BASE_URL + UrlConstants.get_company_accesses
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                print("company access response is \(response)")
                self.access = Int(response["access"] as! String)!
            }) { (error) in
                // failed to get company access
            }
        }
    }

    // MARK: - Core Data stack

//    lazy var persistentContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentContainer(name: "Medication")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                 
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()

    // MARK: - Core Data Saving support

//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
    
    
    /*******************************    NEW METHODS COMPATIBLE WITH LOWER IOS VERSIONS     *************************************/
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Medication")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
    
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Medication", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Medication.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if #available(iOS 10.0, *) {
            
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
                
            } else {
                // iOS 9.0 and below - however you were previously handling it
                if managedObjectContext.hasChanges {
                    do {
                        try managedObjectContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                }
                
            }
        }
    }

}

