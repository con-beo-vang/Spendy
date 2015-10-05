//
//  User.swift
//  Spendy
//
//  Created by Harley Trung on 9/28/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
import Parse

class User: HTObject {
    static func current() -> User? {
        guard let object = PFUser.currentUser() else { return nil }
        return User(object: object)
    }

    var name: String? {
        get { return self["name"] as! String? }
        set { self["name"] = newValue }
    }

    var username: String? {
        get { return self["username"] as! String? }
        set { self["username"] = newValue }
    }

    var password: String? {
        get { return self["password"] as! String? }
        set { self["password"] = newValue }
    }

    var email: String? {
        get { return self["email"] as! String? }
        set { self["email"] = newValue }
    }

    var dataVersion: String? {
        get { return self["version"] as! String? }
        set { self["version"] = newValue }
    }

    convenience init() {
        self.init(object: PFUser())
    }

    var object: PFUser? {
        return _object as! PFUser?
    }

    class func isDataVersionOutOfDate() -> Bool {
        guard let user = User.current() else { return true }
        return user.dataVersion != DataManager.version
    }

    func updateDataVersion(version: String) {
        dataVersion = version
        save()
    }
}