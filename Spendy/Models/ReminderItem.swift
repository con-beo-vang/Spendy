//
//  ReminderItem.swift
//  Spendy
//
//  Created by Harley Trung on 10/18/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import RealmSwift

class ReminderItem: HTRObject {
  dynamic var userCategory: UserCategory?
  dynamic var reminderTime: NSDate?
  dynamic var UUID: String?
  dynamic var isActive = false
  
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
  
  // default value stored in DB
  // TODO: cleverly update this over time
  var predictedAmount = 450
  
  var predictedAmountDecimal: NSDecimalNumber {
    get { return DecimalConverter.intToDecimal(predictedAmount) }
    set { predictedAmount = DecimalConverter.decimalToInt(newValue) }
  }
  
  func formattedPredictedAmount() -> String {
    if let s = Currency.currencyFormatter.stringFromNumber(predictedAmount) {
      return s
    } else {
      return "Unknown"
    }
  }
  
  // Specify properties to ignore (Realm won't persist these)
  override static func ignoredProperties() -> [String] {
    return ["predictedAmountDecimal"]
  }
  
  override func save() {
    let realm = try! Realm()
    
    try! realm.write {
      self.setIdIfNeeded(realm)
      
      if let userCat = self.userCategory {
        userCat.timeSlots.append(self)
      }
    }
  }
}
