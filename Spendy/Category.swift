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

    class func loadAll() {
        // load from local first
        let localQuery = PFQuery(className: "Category")

        localQuery.fromLocalDatastore().findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in

            if let error = error {
                print("Error loading categories from Local: \(error)", terminator: "\n")
                return
            }

            _allCategories = objects?.map({ Category(object: $0 ) })
            print("\n[local] categories: \(objects)", terminator: "\n")

            if _allCategories == nil || _allCategories!.isEmpty {
                print("No categories found locally. Loading from server", terminator: "\n")
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
                            print("bool: \(success); error: \(error)")
                        })
                        // no need to save because we are not adding data
                    }
                }
            }
        }
    }

    class func defaultCategory() -> Category? {
        return _allCategories?.first
    }

    class func all() -> [Category]? {
        return _allCategories;
    }

    class func findById(objectId: String) -> Category? {
        let record = _allCategories?.filter({ (el) -> Bool in
            el.objectId == objectId
        }).first
        return record
    }
}

//extension Category: CustomStringConvertible {
//    override var description: String {
//        let base = super.description
//        return "name: \(name), icon: \(icon), base: \(base)"
//    }
//}