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
                return false
            }
        }
        set {
            let oldValue = reminderOn
            self["reminderOn"] = newValue
            if oldValue != newValue {
                save()
            }
        }
    }

    var predictedAmount = NSDecimalNumber(double: 20)

    var timeSlots: [ReminderItem] {
        set {
            self["timeSlots"] = newValue.map({$0._object!})
        }
        get {
            if let objects = self["timeSlots"] as! [PFObject]? {
                do {
                    try PFObject.fetchAllIfNeeded(objects)
                    return objects.map{ ReminderItem(object: $0) }
                } catch {
                    // remove invalid objects
                    PFObject.unpinAllInBackground(objects)
                    PFObject.deleteAllInBackground(objects)
                    self["timeSlots"] = []
                    return []
                }
            } else {
                self["timeSlots"] = []
                return []
            }
        }
    }

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

    var name: String { return category.name }
    var icon: String { return category.icon }

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
        save()

        print("add notification for \(item) at \(time)")
        ReminderList.sharedInstance.addReminderNotification(item)
    }

    func removeReminder(item: ReminderItem) {
        print("remove old notification for \(item)")
        ReminderList.sharedInstance.removeReminderNotification(item)
        timeSlots = timeSlots.filter {$0.UUID != item.UUID}
        item.delete()
        save()
    }

    func updateReminder(index: Int, newTime: NSDate) {
        let item = timeSlots[index]

        ReminderList.sharedInstance.removeReminderNotification(item)

        item.reminderTime = newTime

        // Turn on switch automatically
        item.isActive = true
        item.save()

        // Add new notification
        ReminderList.sharedInstance.addReminderNotification(item)
    }

    func updateReminder(reminderItem: ReminderItem, newValue: Bool) {
        reminderItem.isActive = newValue
        reminderItem.save()

        // attempt to remove reminderItem first
        ReminderList.sharedInstance.removeReminderNotification(reminderItem)

        if newValue {
            ReminderList.sharedInstance.addReminderNotification(reminderItem)
        }

        checkReminderOnStatus()
    }

    func removeSelfAndAllReminders() {
        for item in timeSlots {
            removeReminder(item)
        }
        delete()
    }

    func turnOff() {
        reminderOn = false
        for t in timeSlots {
            if t.isActive {
                // turn off notification but keep values
                // t.isActive = false
                ReminderList.sharedInstance.removeReminderNotification(t)
            }
        }
    }

    func turnOn() -> Bool {
        let activeSlots = timeSlots.filter {$0.isActive}

        guard !activeSlots.isEmpty else {
            reminderOn = false
            return false
        }

        reminderOn = true

        for t in activeSlots {
            if t.isActive {
                ReminderList.sharedInstance.addReminderNotification(t)
            }
        }
        return true
    }

    func checkReminderOnStatus() {
        let activeSlots = timeSlots.filter {$0.isActive}

        if activeSlots.isEmpty && reminderOn {
            reminderOn = false
            return
        }
    }

    class func fromCategories(categories: [Category]) -> [UserCategory] {
        return categories.map({ findByCategoryId($0.objectId!)! })
    }
}

var _allForQuickAdd: [UserCategory]?

// MARK: - Quick Add
extension UserCategory {
    class func allForQuickAdd() -> [UserCategory] {
        guard _allForQuickAdd != nil else {
            let defaultCategoryNames = ["Meal", "Drink", "Commute"]
            let cats = Category.all.filter({ defaultCategoryNames.contains($0.name) })
            _allForQuickAdd = fromCategories(cats)
            return _allForQuickAdd!
        }

        return _allForQuickAdd!

    }

    func quickAddAmounts() -> [NSDecimalNumber] {
        let amounts = [5, 10, 50].map({ NSDecimalNumber(double: $0) })
        // TODO: retrieve the above dynamically
        return amounts
    }
}