//
//  ReminderItem.swift
//  Spendy
//
//  Created by Dave Vo on 9/28/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

struct ReminderItem {
    var userCategory: UserCategory?
    var reminderTime: NSDate

    var UUID: String
    var isActive: Bool
    
    init(userCategory: UserCategory, reminderTime: NSDate, UUID: String) {
        self.userCategory = userCategory
        self.reminderTime = reminderTime
        self.UUID = UUID
        self.isActive = true
    }

    var category: Category? {
        return userCategory?.category
    }

    var predictedAmount: NSNumber = 0
}
