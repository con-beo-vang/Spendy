//
//  ReminderItem.swift
//  Spendy
//
//  Created by Dave Vo on 9/28/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

struct ReminderItem {
    var category: String
    var predictiveAmount: NSDecimalNumber
    var reminderTime: NSDate
    var UUID: String
    
    init(category: String, predictiveAmount: NSDecimalNumber, reminderTime: NSDate, UUID: String) {
        self.category = category
        self.predictiveAmount = predictiveAmount
        self.reminderTime = reminderTime
        self.UUID = UUID
    }
    
    //    var isOverdue: Bool {
    //        return (NSDate().compare(self.deadline) == NSComparisonResult.OrderedDescending) // deadline is earlier than current date
    //    }
}
