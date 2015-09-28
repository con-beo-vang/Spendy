//
//  ReminderList.swift
//  Spendy
//
//  Created by Dave Vo on 9/28/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class ReminderList: NSObject {
    static let sharedInstance = ReminderList()
    
    func addReminderNotification(category: String, amount: NSDecimalNumber, date: NSDate) {
        let item = ReminderItem(category: category, predictiveAmount: amount, reminderTime: date, UUID: NSUUID().UUIDString)
        
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = "Good day! Did you spend $\(item.predictiveAmount) on \(item.category)?" // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = item.reminderTime // todo item due date (when notification will be fired)
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["category": item.category, "predictiveAmount": item.predictiveAmount, "UUID": item.UUID] // assign a unique identifier to the notification so that we can retrieve it later
        notification.category = "REMINDER_CATEGORY"
        notification.repeatInterval = NSCalendarUnit.Day
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func removeReminderNotification(item: ReminderItem) {
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == item.UUID) { // ...and cancel the notification that corresponds to this ReminderItem instance (matched by UUID)
                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
    }
    
    // Snooze
    func scheduleReminderforItem(item: ReminderItem) {
        let notification = UILocalNotification() // create a new reminder notification
        notification.alertBody = "Good day! Did you spend $\(item.predictiveAmount) on \(item.category)?" // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = NSDate().dateByAddingTimeInterval(30 * 60) // 30 minutes from current time
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["category": item.category, "predictiveAmount": item.predictiveAmount, "UUID": item.UUID] // assign a unique identifier to the notification that we can use to retrieve it later
        notification.category = "REMINDER_CATEGORY"
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
