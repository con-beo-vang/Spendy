//
//  RCategory.swift
//  Spendy
//
//  Created by Harley Trung on 10/17/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import RealmSwift

let transferCats = [
    "Transfer"
]

let incomeCats = [
    "Bonus",
    "Other",
    "Salary",
    "Saving Deposit",
    "Tax Refund"
]

let expenseCats = [
    "Auto",
    "Bank Charge",
    "Book",
    "Cash",
    "Charity",
    "Child Care",
    "Clothing",
    "Commute",
    "Credit Card Payment",
    "Drink",
    "Education",
    "Electric",
    "Entertainment",
    "Garbage & Recycling",
    "Gift",
    "Groceries",
    "Health & Fitness",
    "Home Repair",
    "House Hold",
    "Insurance",
    "Internet",
    "Loan",
    "Meal",
    "Medical",
    "Movie",
    "Other",
    "Pet",
    "Rent",
    "Tax",
    "Telephone",
    "Travel",
    "TV",
    "Water"
]


class RCategory: HTRObject {
    dynamic var name: String? = nil
    dynamic var icon: String? = nil

    // TODO: can type be enum?
    var type: String? {
        return icon?.componentsSeparatedByString("-").first
    }

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }

    static func defaultCategory() -> RCategory {
        let category = try! Realm().objects(RCategory).first
        return category!
    }

    // TODO: implement
    static func defaultCategoryFor(type: String) -> RCategory {
        return defaultCategory()
    }

    static func bootstrap() {
        let realm = try! Realm()

        var objects = [RCategory]()

        for (index, name) in expenseCats.enumerate() {
            let c = RCategory()
            c.id = index
            c.name = name
            c.icon = "Expense-\(name)"
            objects.append(c)
        }

        try! realm.write {
            realm.add(objects, update: true)
        }
    }

}
