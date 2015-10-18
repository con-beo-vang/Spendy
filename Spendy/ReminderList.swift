//
//  ReminderList.swift
//  Spendy
//
//  Created by Dave Vo on 9/28/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
//import Parse

class ReminderList: NSObject {
    static let sharedInstance = ReminderList()
    
    func addReminderNotification(item: ReminderItem) {
        let category = item.category!
        
        // create a corresponding local notification
        let notification = UILocalNotification()

        // text that will be displayed in the notification
        notification.alertBody = "Good day! Did you spend $\(item.predictedAmount) on \(category.name)?"

        // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.alertAction = "open"

        // todo item due date (when notification will be fired)
        notification.fireDate = item.reminderTime

        // play default sound
        notification.soundName = UILocalNotificationDefaultSoundName

        // assign a unique identifier to the notification so that we can retrieve it later
        notification.userInfo = ["categoryId": category.id, "predictedAmount": item.predictedAmount, "UUID": item.UUID!]

        notification.category = "REMINDER_CATEGORY"

        // daily reminders
        notification.repeatInterval = NSCalendarUnit.Day

        UIApplication.sharedApplication().scheduleLocalNotification(notification)

        print("[Notification] Scheduled \(item.UUID). Total: #\(notifications().count)]")
    }

    func removeReminderNotification(item: ReminderItem) {
        guard let itemUUID = item.UUID else { return }

        for notification in notifications() { // loop through notifications...
            // ...and cancel the notification that corresponds to this ReminderItem instance (matched by UUID)
            if (notification.userInfo!["UUID"] as! String == itemUUID) {
                // there should be a maximum of one match on UUID
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                print("[Notification] Removed \(itemUUID). Total: #\(notifications().count)]")
                break
            }
        }
    }

    func notifications() -> [UILocalNotification] {
        return UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification]
    }

    // Snooze
    func scheduleReminderforItem(item: ReminderItem) {
        let category = item.category!
        
        let notification = UILocalNotification() // create a new reminder notification
        notification.alertBody = "Good day! Did you spend $\(item.predictedAmount) on \(category.name)?" // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = NSDate().dateByAddingTimeInterval(30 * 60) // 30 minutes from current time
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["categoryId": category.id, "predictiveAmount": item.predictedAmount, "UUID": item.UUID!] // assign a unique identifier to the notification that we can use to retrieve it later
        notification.category = "REMINDER_CATEGORY"
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
