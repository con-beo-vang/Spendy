//
//  ReminderItem.swift
//  Spendy
//
//  Created by Dave Vo on 9/28/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

struct ReminderItem {
    
    var categoryId: String?
//    var category: String
//    var predictiveAmount: NSDecimalNumber
    var reminderTime: NSDate
    var UUID: String
    var isActive: Bool
    
    init(category: Category, reminderTime: NSDate, UUID: String) {
        self.categoryId = category.objectId
//        self.predictiveAmount = predictiveAmount
        self.reminderTime = reminderTime
        self.UUID = UUID
        self.isActive = true
    }
    
    var category: Category? {
        set {
            categoryId = newValue?.objectId
        }
        
        get {
            return Category.findById(categoryId!)
        }
    }
    
    
}
