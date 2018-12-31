//
//  AppDelegate.swift
//  Nosedive
//
//  Created by Victor Santos on 12/30/17.
//  Copyright © 2017 itsoluclick. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Fabric
import Crashlytics
import GoogleMobileAds

import FacebookCore


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
         FirebaseApp.configure()
        
         application.statusBarStyle = .lightContent 
        
      attempRegisterForNotifications(application: application)
        
        Fabric.with([Crashlytics.self])
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9751546392416390~7842552342")
       
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Registrered with FCM with token", fcmToken)
    }
    
    //listen for user notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("registered for notifications", deviceToken)
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let fromUserId = userInfo["fromUserId"] as? String {
            print(fromUserId)
            
            NotificationCenter.default.post(name: MainAppViewController.userWhoRated, object: nil, userInfo: userInfo)
            UIApplication.shared.applicationIconBadgeNumber = 0
            
//            UserModel().getUserById(uid: fromUserId, completion: { (userData) in
//                userRating.userData = userData
//
//
//                self.window?.rootViewController = MainAppViewController();
//                if let mainController = self.window?.rootViewController {
//
//                    DispatchQueue.main.async {
//                          mainController.performSegue(withIdentifier: "ratingView", sender: nil)
//                    }
//
//                }else{
//                    print("failed")
//                }
//            })
            
        }
    }
    
    
    
    func attempRegisterForNotifications(application: UIApplication) {
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        print("registering")
        
        //all for iOS 10+
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
            if let err = err {
                print("Failed to request auth.", err)
            }
            
            if granted {
                print("Auth granted.")
            }else{
                print("Auth denied")
            }
        }
        application.registerForRemoteNotifications()
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
         AppEventsLogger.activate(application)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return SDKApplicationDelegate.shared.application(application, open: url, options: options)
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return SDKApplicationDelegate.shared.application(application,
                                                         open: url,
                                                         sourceApplication: sourceApplication,
                                                         annotation: annotation)
    }
 
   
    

}

