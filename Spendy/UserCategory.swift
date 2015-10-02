//
//  UserCategory.swift
//  Spendy
//
//  Created by Harley Trung on 10/2/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation
import Parse

class UserCategory: HTObject {
    static var forceLoadFromRemote = false

    var userId: String {
        get { return self["userId"] as! String }
        set { self["userId"] = newValue }
    }

    var categoryId: String {
        get { return self["categoryId"] as! String }
        set { self["categoryId"] = newValue }
    }

    var _category: Category?
    var category: Category {
        get {
            if _category == nil {
                _category = Category.findById(categoryId)
            }

            return _category!
        }
        set {
            _category = newValue
            self["categoryId"] = newValue.objectId
        }
    }

     // Add for reminder
    var reminderOn : Bool {
        get {
            if let val = self["reminderOn"] as! Bool? {
                return val
            } else {
                self.reminderOn = false
                return false
            }
        }
        set { self["reminderOn"] = newValue }
    }

    var predictedAmount = NSDecimalNumber(double: 20)
    var timeSlots = [ReminderItem]()

    convenience init(category: Category) {
        self.init()
        self.category = category
        self.userId = User.current()!.objectId!
    }

    convenience init(categoryId: String) {
        self.init()
        self.categoryId = categoryId
        self.userId = User.current()!.objectId!
    }

    var name: String? {
        return category.name
    }

    static var _all: [UserCategory]?

    class var all: [UserCategory] {
        if _all == nil {
            let user = PFUser.currentUser()!

            let query = PFQuery(className: "UserCategory")
            query.whereKey("userId", equalTo: user.objectId!)

            if !forceLoadFromRemote {
                query.fromLocalDatastore()
            }
            let objects = try! query.findObjects()
            _all = objects.map({ UserCategory(object: $0) })
        }

        return _all!
    }
}

// MARK - Category stuff
extension UserCategory {
    class func findByCategoryId(catId:String) -> UserCategory? {
        let uc = all.filter({$0.categoryId == catId}).first
        if uc == nil {
            let a = UserCategory(categoryId: catId)
            a.save()
            _all!.append(a)
            return a
        } else {
            return uc
        }
    }
}

// MARK - Reminder stuff
extension UserCategory {
    // returns categories that have at least one reminder item
    class func allWithReminderSettings() -> [UserCategory] {
        return all.filter({ !$0.timeSlots.isEmpty })
    }

    func addReminder(time: NSDate) {
        let item = ReminderItem(userCategory: self, reminderTime: time, UUID: NSUUID().UUIDString)
        timeSlots.append(item)

        if self.isNew() {
            save()
        }

        print("add notification for \(item) at \(time)")
        ReminderList.sharedInstance.addReminderNotification(item)
    }

    func removeReminder(item: ReminderItem) {

        print("remove old notification")
        ReminderList.sharedInstance.removeReminderNotification(item)
    }

    func updateReminder(index: Int, newTime: NSDate) {
        var item = timeSlots[index]

        ReminderList.sharedInstance.removeReminderNotification(item)

        item.reminderTime = newTime
        // Turn on switch automatically
        item.isActive = true

        // Add new notification
        ReminderList.sharedInstance.addReminderNotification(item)
    }
}