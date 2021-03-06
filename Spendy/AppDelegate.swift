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
    // Parse.enableLocalDatastore()
    
    // ****************************************************************************
    // Uncomment this line if you want to enable Crash Reporting
    // ParseCrashReporting.enable()
    
    guard getCredential() else {
      return false
    }
    
    configParse(application, launchOptions: launchOptions)
    settingNotification(application)
    configAppearance()
    configNotificationCenter()
    
    PFUser.currentUser()?.fetchIfNeededInBackground()
    print("=====================\nUser: \(PFUser.currentUser())\n=====================")
    
    return true
  }
  
  func getCredential() -> Bool {
    guard let config = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!) else {
      print("Please set up Parse keys in Config.plist file", terminator: "\n")
      return false
    }
    
    let applicationId = config["parse_application_id"] as? String
    let clientKey = config["parse_client_key"] as? String
    Parse.setApplicationId(applicationId!, clientKey: clientKey!)
    return true
  }
  
  func configAppearance() {
    Color.isGreen = NSUserDefaults.standardUserDefaults().boolForKey("DefaultTheme") ?? true
    
    UINavigationBar.appearance().barTintColor = Color.strongColor
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    
    UITabBar.appearance().tintColor = Color.strongColor
  }
  
  func configParse(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
    // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
    // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
    // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
    // PFFacebookUtils.initializeFacebook()
    // ****************************************************************************
    
    // allows anonymousm users
    // PFUser.enableAutomaticUser()
    
    let defaultACL = PFACL();
    
    // If you would like all objects to be private by default, remove this line.
//    defaultACL.setPublicReadAccess(true)

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
  }
  
  func configNotificationCenter() {
    print("<<<<<<<<<<\nNotifications: \(ReminderList.sharedInstance.notifications())\n>>>>>>>>>>")
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "recomputeAccountBalance:", name: SPNotification.transactionsLoadedForAccount, object: nil)
    
    // This may not be necessary due to the above
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncRemoteAccountsIfNecessary:", name: SPNotification.allAccountsLoadedLocally, object: nil)
  }
  
  // We already have accounts loaded locally
  // We still want to check with remote in case there are no local accounts or there are new ones saved from another device
  //    func syncRemoteAccountsIfNecessary(notification: NSNotification) {
  //        // TODO: only do this if necessary (e.g. we know there server has something different)
  //        print("[Notified] sync remote accounts:")
  //        Account.loadAllFrom(local: false)
  //    }
  
  func recomputeAccountBalance(notification: NSNotification) {
    // First try to cast user info to expected type
    guard let info = notification.userInfo as? Dictionary<String,AnyObject> else {
      print("[transactionLoadedForAccountCallback] Cannot cast userInfo \(notification.userInfo)")
      return
    }
    
    guard let account = info["account"] as! Account? else { return }
    
    BalanceComputing.recompute(account)
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
    // The unique identifier for this action
    completeAction.identifier = "CHANGE"
    // Title for the action button
    completeAction.title = "Change"
    completeAction.activationMode = .Foreground
    // Don't require unlocking before performing action
    completeAction.authenticationRequired = false
    // Display action in red
    completeAction.destructive = true
    
    let remindAction = UIMutableUserNotificationAction()
    remindAction.identifier = "YES"
    remindAction.title = "Yes"
    // Don't bring app to foreground
    remindAction.activationMode = .Background
    remindAction.destructive = false
    
    // Notification categories allow us to create groups of actions 
    // that we can associate with a notification
    let todoCategory = UIMutableUserNotificationCategory()
    todoCategory.identifier = "REMINDER_CATEGORY"
    // UIUserNotificationActionContext.Default (4 actions max)
    todoCategory.setActions([remindAction, completeAction], forContext: .Default)
    // UIUserNotificationActionContext.Minimal - for when space is limited (2 actions max)
    todoCategory.setActions([completeAction, remindAction], forContext: .Minimal)
    
    // We're now providing a set containing our category as an argument
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: NSSet(array: [todoCategory]) as? Set<UIUserNotificationCategory>))
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    let categoryId = notification.userInfo!["categoryId"] as! Int
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
      let t = Transaction(kind: CategoryType.Expense.rawValue, note: nil, amountDecimal: item.predictedAmountDecimal, category: item.category!, account: Account.defaultAccount(), date: NSDate())
      t.save()
      
    default: // switch statements must be exhaustive - this condition should never be met
      print("Error: unexpected notification action identifier!")
    }
    completionHandler() // per developer documentation, app will terminate if we fail to call this
  }
  
}
