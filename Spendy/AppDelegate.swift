//
//  AppDelegate.swift
//  Spendy
//
//  Created by Harley Trung on 9/13/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import Parse

// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        
        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        
        guard let config = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!) else {
            print("Please set up Parse keys in Config.plist file", terminator: "\n")
            return false
        }
        
        // print("loaded config: \(config)")
        let applicationId = config["parse_application_id"] as? String
        let clientKey = config["parse_client_key"] as? String
        Parse.setApplicationId(applicationId!, clientKey: clientKey!)
        
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************
        
        // allows anonymousm users
        // PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        // Local notification
        settingNotification(application)
        
        
        // Uncommnet these lines if you want to remove all old notifications
//        for notification in UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]! {
//            UIApplication.sharedApplication().cancelLocalNotification(notification)
//        }
        
        // Config apprearance
        
        Color.isGreen = NSUserDefaults.standardUserDefaults().boolForKey("DefaultTheme") ?? true
        
        UINavigationBar.appearance().barTintColor = Color.strongColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        UITabBar.appearance().tintColor = Color.strongColor
        
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Color.strongColor], forState:.Selected)
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Color.inactiveTabBarIconColor], forState:.Normal)
        
        // Uncomment this out to run if you have more categories to addd
        // Category.bootstrapCategories()

        print("<<<<<<<<<<\nNotifications: \(ReminderList.sharedInstance.notifications())\n>>>>>>>>>>")
        UIApplication.sharedApplication().cancelAllLocalNotifications()


        PFUser.currentUser()?.fetchIfNeededInBackground()
        print("=====================\nUser: \(User.current())\n=====================")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recomputeAccountBalance:", name: SPNotification.transactionsLoadedForAccount, object: nil)

        // This may not be necessary due to the above
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "recomputeAccountBalance:", name: SPNotification.allAccountsLoaded, object: nil)
        return true
    }

    func recomputeAccountBalance(notification: NSNotification) {
        // First try to cast user info to expected type
        guard let info = notification.userInfo as? Dictionary<String,AnyObject> else {
            print("[transactionLoadedForAccountCallback] Cannot cast userInfo \(notification.userInfo)")
            return
        }

        guard let account = info["account"] as! Account? else { return }

        account.recomputeBalance()
        print("[Notified] recomputed balance for \(account.transactions.count) transactions of account \(account.name)")
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.", terminator: "\n");
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error, terminator: "")
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.", terminator: "\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error, terminator: "")
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }
    
    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
    
    //--------------------------------------
    // MARK: - Local Notification
    //--------------------------------------
    
    func settingNotification(application: UIApplication) {
        
        let completeAction = UIMutableUserNotificationAction()
        completeAction.identifier = "CHANGE" // the unique identifier for this action
        completeAction.title = "Change" // title for the action button
        completeAction.activationMode = .Foreground
        completeAction.authenticationRequired = false // don't require unlocking before performing action
        completeAction.destructive = true // display action in red
        
        let remindAction = UIMutableUserNotificationAction()
        remindAction.identifier = "YES"
        remindAction.title = "Yes"
        remindAction.activationMode = .Background // UIUserNotificationActivationMode.Background - don't bring app to foreground
        remindAction.destructive = false
        
        let todoCategory = UIMutableUserNotificationCategory() // notification categories allow us to create groups of actions that we can associate with a notification
        todoCategory.identifier = "REMINDER_CATEGORY"
        todoCategory.setActions([remindAction, completeAction], forContext: .Default) // UIUserNotificationActionContext.Default (4 actions max)
        todoCategory.setActions([completeAction, remindAction], forContext: .Minimal) // UIUserNotificationActionContext.Minimal - for when space is limited (2 actions max)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: NSSet(array: [todoCategory]) as? Set<UIUserNotificationCategory>)) // we're now providing a set containing our category as an argument
        
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {

        let categoryId = notification.userInfo!["categoryId"] as! String!
        let userCategory = UserCategory.findByCategoryId(categoryId)!

        let item = ReminderItem(userCategory: userCategory, reminderTime: notification.fireDate!, UUID: notification.userInfo!["UUID"] as! String!)
        
        switch (identifier!) {
        case "CHANGE":
            print("CHANGE")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "GoToQuickAdd")
            let vc = storyboard.instantiateViewControllerWithIdentifier("SplashVC") as! SplashViewController
            window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
        case "YES":
            print("YES")
            // TODO: Add new transaction
            item.category?.save()
        default: // switch statements must be exhaustive - this condition should never be met
            print("Error: unexpected notification action identifier!")
        }
        completionHandler() // per developer documentation, app will terminate if we fail to call this
    }
    
}
