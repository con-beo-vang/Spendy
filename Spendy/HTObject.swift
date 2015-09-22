//
//  HTObject.swift
//  Spendy
//
//  Created by Harley Trung on 9/20/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Foundation
import Parse

// Goal:
// - abstract away communication with Parse
// - provide useful syntactic sugar
//
// Inherit from NSObject so that we can use #setValue and #valueForKey
class HTObject: NSObject {
    var _object: PFObject?

    subscript(key: String) -> AnyObject? {
        get {
            return valueForKey(key)
        }
        set {
            setProperty(key, value: newValue)
        }
    }
    
    // Setter so we can also update the internal Parse object
    func setProperty(key: String, value: AnyObject?) {
        setValue(value, forKey: key)
        if value != nil {
            _object!.setObject(value!, forKey: key)
        }
    }
    
    // Should be called after we make any changes
    func save() {
        println("pining and saving: \(self) \(toString())")
        _object!.pinInBackground()
        _object!.saveInBackground()
    }
    
    func toString() -> String! {
        return "\(_object)"
    }
}