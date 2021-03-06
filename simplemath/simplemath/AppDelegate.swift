//
//  AppDelegate.swift
//  simplemath
//
//  Created by Vineeth Vijayan on 04/08/16.
//  Copyright © 2016 creativelogics. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init(){
        FIRApp.configure()
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let textAction = UIMutableUserNotificationAction()
        textAction.identifier = "TEXT_ACTION"
        textAction.title = "Reply"
        textAction.activationMode = .background
        textAction.isAuthenticationRequired = false
        textAction.isDestructive = false
        textAction.behavior = .textInput
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "CATEGORY_ID"
        category.setActions([textAction], for: .default)
        category.setActions([textAction], for: .minimal)
        
        let categories = NSSet(object: category) as! Set<UIUserNotificationCategory>
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        
        let token = FIRInstanceID.instanceID().token()!
        print("FCM Token")
        print(token)
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Device Token")
        print(deviceToken)
        
        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.sandbox)
        FIRMessaging.messaging().subscribe(toTopic: "/topics/allusers")
//        let token = FIRInstanceID.instanceID().token()!
//        print(token)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        let reply = responseInfo[UIUserNotificationActionResponseTypedTextKey] as! String
        
        print("%@", userInfo)

        var strAlert = " "
        strAlert = strAlert + userInfo["num1"]!.description + " "
        strAlert = strAlert + userInfo["num2"]!.description + " "
        strAlert = strAlert + userInfo["action"]!.description + " "
        
        if let num1 = userInfo["num1"]!.description {
            if let num2 = userInfo["num2"]!.description{
                if let action = userInfo["action"]!.description {
                    if let result = userInfo["result"]!.description {
                        uploadAnalytics(num1: num1, num2: num2, action: action, result: result, reply: reply)
                    }
                }
            }
        }
        
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
    }
    
    func application(_ application: UIApplication,
                     open url: URL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }

}

