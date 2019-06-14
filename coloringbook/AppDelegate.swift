//
//  AppDelegate.swift
//  coloringbook
//
//  Created by Iulian Dima on 5/10/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit
import GoogleMobileAds
import UserNotifications
import Branch
import Pyze
import YandexMobileMetrica
import FacebookCore
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.configure(withApplicationID: Constants.AdMobAppId);
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor(hex: 0x39B68A)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(granted, error) in
                if granted {
                    if !UserDefaults.standard.bool(forKey: "notification_added") {
                        UserDefaults.standard.set(true, forKey: "notification_added")
                        UserDefaults.standard.set(NSDate().toInteger(), forKey: "notification_added_time")
                        
//                        LocalNotificationManager.sharedInstance.createNotification("newItem", title: NSLocalizedString("appName", comment: ""), message: NSLocalizedString("notify_msg", comment: ""), date: DateComponent(day: 0, hour: 11, minute: 0, second: 0))
                        
                        LocalNotificationManager.sharedInstance.stopAllDeliveredNotifications()
                        LocalNotificationManager.sharedInstance.stopAllPendingNotifications()
                        
                        let today = NSDate()
                        let fireDay = today + DateComponent(day: 1, hour: 0, minute: 0, second: 0)
                        LocalNotificationManager.sharedInstance.createNotification("newItem", title: NSLocalizedString("appName", comment: ""), message: NSLocalizedString("notify_msg", comment: ""), time: fireDay.timeIntervalSinceNow)
                    }
                }
            })
            
        } else {
        }
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: Constants.oneSignalID) { (result) in
        }
        
        Pyze.initialize(Constants.pyzeID, withLogThrottling: .PyzelogLevelMinimal)
        
        YMMYandexMetrica.activate(withApiKey: Constants.metrikaID)
        
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: nil)

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshCategory"), object: nil, userInfo: nil)
        
        completionHandler([.alert,.sound,.badge])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        Branch.getInstance().handleDeepLink(url)
        
        return SDKApplicationDelegate.shared.application(application,
                                                         open: url,
                                                         sourceApplication: sourceApplication,
                                                         annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("applicationDidReceiveMemoryWarning")
    }
}

