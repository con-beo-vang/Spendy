//
//  Category.swift
//  Spendy
//
//  Created by Harley Trung on 9/18/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Foundation
import Parse

var _allCategories: [Category]?

class Category: HTObject {
    static let incomeCats = [
        "Bonus",
        "Other",
        "Salary",
        "Saving Deposit",
        "Tax Refund"
    ]

    static let expenseCats = [
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

    var name: String {
        get { return self["name"] as! String }
        set { self["name"] = newValue }
    }

    var userId: String {
        get { return self["userId"] as! String }
        set { self["userId"] = newValue }
    }

    var icon: String {
        get { return self["icon"] as! String }
        set { self["icon"] = newValue }
    }

    static var forceLoadFromRemote = false

    convenience init(name: String?, icon: String?) {
        self.init()
        if let name = name {
            self.name = name
        }

        if let icon = icon {
            self.icon = icon
        }
    }

    class func loadAll() {
        // load from local first
        let query = PFQuery(className: "Category")
        query.limit = 100

        if !forceLoadFromRemote {
            query.fromLocalDatastore()
        }

        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in

            guard let objects = objects where error == nil else {
                print("Error loading categories from Local. error: \(error)")
                return
            }

            _allCategories = objects.map({ Category(object: $0 ) })
            print("\n[local] categories: \(objects)")

            if _allCategories!.isEmpty {
                print("No categories found locally. Loading from server")
                // load from remote
                let remoteQuery = PFQuery(className: "Category")
                remoteQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if let error = error {
                        print("Error loading categories from Server: \(error)")
                    } else {
                        print("[server] categories: \(objects)")
                        _allCategories = objects?.map({ Category(object: $0 ) })

                        // already in background
                        PFObject.pinAllInBackground(objects!, withName: "MyCategories", block: { (success, error: NSError?) -> Void in
                            print("success: \(success); error: \(error)")
                        })
                        // no need to save because we are not adding data
                    }
                }
            }
        }
    }

    class func defaultCategory() -> Category? {
        return all.first
    }

    class var all:[Category] {
        if _allCategories == nil {
            let query = PFQuery(className: "Category")
            if !forceLoadFromRemote {
                query.fromLocalDatastore()
            }
            let objects = try! query.fromLocalDatastore().findObjects()
            _allCategories = objects.map({ Category(object: $0) })
        }

        return _allCategories!
    }

    class func findById(objectId: String) -> Category? {
        let record = all.filter({ $0.objectId == objectId }).first
        return record
    }

    override var description: String {
        let base = super.description
        return "[Category] name: \(name), icon: \(icon), base: \(base)"
    }
}

// preload categories
// only have to do this once each time setting up a new Parse app
// you will need to run this manually if you use your own Parse key
// safe to run again as it doesn't create new categories if already set up
extension Category {
    class func bootstrapCategories() {
        print("\n********BOOTSTRAPING CATEGORIES********")

        let query = PFQuery(className: "Category")
        query.limit = 100
        let objects = try! query.findObjects()
        print("Found: \(objects.count) existing categories")

        loadType("Category", names: expenseCats, objects: objects)
        loadType("Income", names: incomeCats, objects: objects)
    }

    class func loadType(type: String, names: [String], objects: [PFObject]) {
        for name in names {
            let category:PFObject? = objects.filter({ (element) -> Bool in
                if let n = element.objectForKey("name") as! String? {
                    return n == name
                } else {
                    return false
                }
            }).first

            if category == nil {
                let sanitizedName = name.stringByReplacingOccurrencesOfString(" ", withString: "")
                let iconName = "\(type)-\(sanitizedName)"
                let c = Category(name: name, icon: iconName)
                c._object!.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                    if succeeded {
                        print("Added \(type) category \(name)")
                    }
                })
            } else {
                print("Found \(name). No change")
            }
        }

        forceLoadFromRemote = true
    }
}