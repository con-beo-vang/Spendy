//
//  HTObject.swift
//  Spendy
//
//  Created by Harley Trung on 9/20/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

// Goal:
// - abstract away communication with Parse
// - provide useful syntactic sugar

// Implmentation notes:
// Inherit from NSObject so that we can use #setValue and #valueForKey

import Foundation
import Parse

class HTObject: NSObject {
    // use an internal object to talk to Parse instead of inheriting from PFObject
    var _object: PFObject?

    // by default, _parseClassName is the class name of the child class
    var _parseClassName: String?

    // an additional id column so we can perform deleting from array easily
    // instead of relying on PFObject's objectId and localId
    var uuid: String!

    // Example:
    // class Person: HTObject {
    // }
    // We will automatically have Person's _object set up as PFObject(className: "Person")
    override convenience init() {
        let childClassName = NSStringFromClass(self.dynamicType)
        let name = childClassName.componentsSeparatedByString(".").last!

        self.init(parseClassName: name)
    }

    // Allow setting a custom class name, if required, such as:
    // var person = Person(parseClassName: "People")
    init(parseClassName: String) {
        super.init()

        uuid = NSUUID().UUIDString
        _parseClassName = parseClassName
        _object = PFObject(className: _parseClassName!)
        // print("init \(parseClassName)")
    }

    // This provides a way to instantiate from an existing object received from Parse
    init(object: PFObject) {
        super.init()

        uuid = NSUUID().UUIDString
        _parseClassName = object.parseClassName
        _object = object
        // print("init \(object.parseClassName) from object: \(object)")
    }

    // internal: this abstracts out our delegation of loading and saving
    // attributes values from and to Parse
    // Ex:
    //   a["key"] = newValue
    //   //=> background: call setObject on _object
    //   // Note we would still need to save _object separately
    subscript(key: String) -> AnyObject? {
        get {
            return _object!.valueForKey(key)
        }
        set {
            if newValue != nil {
                _object!.setObject(newValue!, forKey: key)
            }
        }
    }

    // Child class can override this to add simple validations
    func isValid() -> Bool {
        return _object != nil
    }

    // Should be called after we make any changes
    func save() {
        if isValid() {
            _object!.pinInBackgroundWithBlock { (success, error) -> Void in
                print("pinInBackground: \(self). success: \(success), error: \(error)")
            }
            _object!.saveInBackgroundWithBlock { (success, error) -> Void in
                print("saveInBackground: \(self). success: \(success), error: \(error)")
            }
        } else {
            print("Cannot save: isValid is false. \(self)")
        }
    }

    // When we want to save fully before proceding to the next step
    // This is mainly for debugging
    func saveSynchronously() {
        if isValid() {
            try! _object!.save()
            try! _object!.pin()
        } else {
            print("Cannot save: isValid is false. \(self)")
        }
    }

    // An object is new if it has not been saved to the server
    // TODO: what about localId?
    func isNew() -> Bool {
        return _object?.objectId == nil
    }

    // Delegate objectId and localId to _object
    var objectId: String? { return _object?.objectId }

    var localId: String? { return _object?.objectForKey("localId") as! String? }

    // TODO: see if this has any use
    func pinAndSaveEventuallyWithName(name: String) {
        _object!.pinInBackgroundWithName(name) { (isSuccess, error) -> Void in
            print("[pinInBackgroundWithName \(name)] \(self). Success: \(isSuccess). ERROR: \(error).")
        }
        _object!.saveEventually()
    }

    class func pinAllWithName(htObjects: [HTObject], name: String) {
        PFObject.pinAllInBackground(htObjects.map({$0._object!}), withName: name) { (isSuccess, error: NSError?) -> Void in
            if error != nil {
                print("[pinAllInBackgrod] withName: \(name). isSuccess: \(isSuccess), error: \(error!). \nFOR: \(htObjects)")
            }
        }
    }

    override var description: String {
        return _object != nil ? "object: \(_object!)" : "object is nil"
    }
}