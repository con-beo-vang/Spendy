//
//  RUserCategory.swift
//  Spendy
//
//  Created by Harley Trung on 10/18/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import RealmSwift

class RUserCategory: HTRObject {
    dynamic var userId: String?
    dynamic var category: Category?

    dynamic var reminderOn = false
    dynamic var predictedAmount: Int = 400

    var predictedAmountDecimal: NSDecimalNumber? {
        get { return DecimalConverter.intToDecimal(predictedAmount) }
        set { predictedAmount = DecimalConverter.decimalToInt(newValue) }
    }

    let timeSlots = List<ReminderItem>()

    var activeSlots: Results<ReminderItem> {
        return timeSlots.filter("isActive == true")
    }

    static var all: [RUserCategory] {
        let realm = try! Realm()
        let objects = realm.objects(RUserCategory)
        return Array(objects)
    }

    var name: String { return category!.name! }
    var icon: String { return category!.icon! }

    // Specify properties to ignore (Realm won't persist these)
    override static func ignoredProperties() -> [String] {
        return ["predictedAmountDecimal"]
    }
}


extension RUserCategory {
    // returns categories that have at least one reminder item
    class func allWithReminderSettings() -> [RUserCategory] {
        return all.filter({ !$0.timeSlots.isEmpty })
    }

    func addReminder(time: NSDate) {
        let item = ReminderItem(userCategory: self, reminderTime: time, UUID: NSUUID().UUIDString)
        item.save()

        print("add notification for \(item) at \(time)")
        ReminderList.sharedInstance.addReminderNotification(item)

        turnOn()
    }

    func removeReminder(item: ReminderItem) {
        print("remove old notification for \(item)")
        ReminderList.sharedInstance.removeReminderNotification(item)

        item.delete()
    }

    func updateReminder(index: Int, newTime: NSDate) {
        let item = timeSlots[index]

        ReminderList.sharedInstance.removeReminderNotification(item)

        let realm = try! Realm()
        try! realm.write {
            item.reminderTime = newTime
            // Turn on switch automatically
            item.isActive = true
        }

        // Add new notification
        ReminderList.sharedInstance.addReminderNotification(item)
    }

    func updateReminder(reminderItem: ReminderItem, newValue: Bool) {
        guard let userCat = reminderItem.userCategory else { return }

        let realm = try! Realm()
        try! realm.write {
            reminderItem.isActive = newValue
        }

        if newValue {
            userCat.turnOn()
        }

        checkReminderOnStatus()
    }

    func removeSelfAndAllReminders() {
        for item in timeSlots {
            removeReminder(item)
        }
//        delete()
    }

    func setReminderFlag(flag: Bool) {
        print("setReminderFlag \(flag)")
        if reminderOn != flag {
            let realm = try! Realm()
            try! realm.write {
                self.reminderOn = flag
            }
        }
    }

    func turnOff() {
        print("turnOff")
        setReminderFlag(false)

        for t in activeSlots {
            // turn off notification but keep values
            ReminderList.sharedInstance.removeReminderNotification(t)
        }
    }

    func turnOn() -> Bool {
        print("turnOn")
        let noActiveSlots = activeSlots.count == 0

        guard noActiveSlots == false else {
            setReminderFlag(false)
            return false
        }

        setReminderFlag(true)

        for t in activeSlots {
            if t.isActive {
                ReminderList.sharedInstance.addReminderNotification(t)
            } else {
                // attempt to remove reminderItem first
                ReminderList.sharedInstance.removeReminderNotification(t)
            }
        }
        return true
    }

    func checkReminderOnStatus() {
        if activeSlots.isEmpty && reminderOn {
            setReminderFlag(false)
            return
        }
    }

    class func fromCategories(categories: [Category]) -> [RUserCategory] {
        // TODO Realm filter
        return categories.map({ findByCategory($0)! })
    }

    class func findByCategory(category: Category) -> RUserCategory? {
        let uc = all.filter({$0.category == category}).first
        if uc == nil {
            let a = RUserCategory()
            a.category = category
            a.save()
            return a
        } else {
            return uc
        }
    }

    class func findByCategoryId(categoryId: Int) -> RUserCategory? {
        let realm = try! Realm()
        let cat = realm.objectForPrimaryKey(Category.self, key: categoryId)
        return findByCategory(cat!)
    }
}

var _allForQuickAdd: [RUserCategory]?

// MARK: - Quick Add
extension RUserCategory {
    class func forceReloadQuickAddCategories() {
        _allForQuickAdd = nil
    }

    class func allForQuickAdd() -> [RUserCategory] {
        guard _allForQuickAdd != nil else {
            _allForQuickAdd = RUserCategory.allWithReminderSettings()

            if _allForQuickAdd!.isEmpty {
                let names = ["Meal", "Drink", "Commute"]
                let cats = Category.all.filter({ names.contains($0.name!) })

                _allForQuickAdd = fromCategories(cats)
            } else {
                // limit to _allForQuickAdd to 3 categories here if desired
            }

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