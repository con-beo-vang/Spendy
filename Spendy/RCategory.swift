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


let stockCategories: [CategoryType: [String]] = [
    .Income:   incomeCats,
    .Expense:  expenseCats,
    .Transfer: transferCats
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
    static func defaultCategoryFor(type: CategoryType) -> RCategory {
        return all.filter({$0.type! == type.rawValue}).first!
    }

    static func bootstrap() {
        let realm = try! Realm()

        var objects = [RCategory]()

        var idSoFar = 1
        for type in CategoryType.allValues {
            for name in stockCategories[type]! {
                let c = RCategory()
                c.id = idSoFar++
                c.name = name

                let sanitizedName = name.stringByReplacingOccurrencesOfString(" ", withString: "")
                c.icon = "\(type.rawValue)-\(sanitizedName)"

                objects.append(c)
            }
        }

        try! realm.write {
            realm.add(objects, update: true)
        }
    }

    func isTransfer() -> Bool {
        return type != nil && type! == CategoryType.Transfer.rawValue
    }

    static var all: [RCategory] {
        return Array(try! Realm().objects(RCategory))
    }

    static func allTyped(type: CategoryType) -> [RCategory] {
//        print("filtering \(type) from: \(all)")
        return all.filter({$0.type! == type.rawValue})
    }

    static func allIncomeType() -> [RCategory] {
        return allTyped(.Income)
    }

    static func allExpenseType() -> [RCategory] {
        return allTyped(.Expense)
    }

    static func allTransferType() -> [RCategory] {
        return allTyped(.Transfer)
    }
}
