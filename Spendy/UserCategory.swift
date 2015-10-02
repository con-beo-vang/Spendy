//
//  UserCategory.swift
//  Spendy
//
//  Created by Harley Trung on 10/2/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation

class UserCategory: HTObject {
    var userId: String {
        get { return self["userId"] as! String }
        set { self["userId"] = newValue }
    }

    var categoryId: String {
        get { return self["categoryId"] as! String }
        set { self["categoryId"] = newValue }
    }

    var _category: Category?
    var category: Category {
        get {
            if _category == nil {
                _category = Category.findById(categoryId)
            }

            return _category!
        }
        set {
            _category = newValue
            self["categoryId"] = newValue.objectId
        }
    }

    convenience init(category: Category) {
        self.init()
        self.category = category
        self.userId = User.current()!.objectId!
    }
}