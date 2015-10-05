//
//  ReminderItem.swift
//  Spendy
//
//  Created by Dave Vo on 9/28/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
import Parse

class ReminderItem: HTObject {
    // user Pointer for relation
    var userCategory: UserCategory? {
        get {
            if let obj = self["userCategory"] as! PFObject? {
                return UserCategory(object: obj)
            }
            else {
                return nil
            }
        }
        set {
            self["userCategory"] = newValue?._object
        }
    }

    var reminderTime: NSDate! {
        get {
            return self["reminderTime"] as! NSDate
        }
        set {
            self["reminderTime"] = newValue
        }
    }

    var UUID: String! {
        get {
            return self["UUID"] as! String
        }
        set {
            self["UUID"] = newValue
        }
    }

    var isActive: Bool {
        get {
            if let iA = self["isActive"] as! Bool? {
                return iA
            } else {
                return false
            }
        }
        set { self["isActive"] = newValue }
    }
    
    convenience init(userCategory: UserCategory, reminderTime: NSDate, UUID: String) {
        self.init()
        
        self.userCategory = userCategory
        self.reminderTime = reminderTime
        self.UUID = UUID
        self.isActive = true
    }

    var category: Category? {
        return userCategory?.category
    }

    // TODO: may set a different predicted amount for reminder
    // for now, pull from UserCategory
    var predictedAmount: NSDecimalNumber {
        get {
            guard let pa = self["predictedAmount"] as! NSNumber? else {
                return userCategory!.predictedAmount
            }
            return NSDecimalNumber(decimal: pa.decimalValue)
        }
        set {
            self["predictedAmount"] = newValue
        }
        
    }

    func formattedPredictedAmount() -> String {
        if let s = Transaction.currencyFormatter.stringFromNumber(predictedAmount) {
            return s
        } else {
            return "Unknown"
        }
    }
}