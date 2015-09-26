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
    var _parseClassName: String?

    override convenience init() {
        let childClassName = NSStringFromClass(self.dynamicType)
        let name = childClassName.componentsSeparatedByString(".").last!

        self.init(parseClassName: name)
    }

    init(parseClassName: String) {
        super.init()
        _parseClassName = parseClassName
        _object = PFObject(className: _parseClassName!)
        print("init for \(_parseClassName)")
    }

    init(object: PFObject) {
        super.init()
        _parseClassName = object.parseClassName
        _object = object
        print("init from object: \(object)")
    }

    func getChildClassName(instance: AnyClass) -> String {
        let name = NSStringFromClass(instance)
        let components = name.componentsSeparatedByString(".")
        return components.last ?? "UnknownClass"
    }

    // a["key"] = newValue
    // --> background: save to Parse, load from Parse
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

    // Should be called after we make any changes
    func save() {
        print("pining + saving in background (no error checking):\n\(self)", terminator: "\n")
        _object!.pinInBackground()
        _object!.saveInBackground()
    }

    func isNew() -> Bool {
        return _object?.objectId == nil
    }

    var objectId: String? {
        return _object?.objectId
    }

    func pinAndSaveEventuallyWithName(name: String) {
        print("pinAndSaveEventually called on\n\(self)", terminator: "\n")
        _object!.pinInBackgroundWithName(name) { (isSuccess, error: NSError?) -> Void in
            if error != nil {
                print("[pinInBackgroundWithName] ERROR: \(error!). For \(self._object)", terminator: "\n")
            }
        }
        _object!.saveEventually()
    }

    class func pinAllWithName(htObjects: [HTObject], name: String) {
        PFObject.pinAllInBackground(htObjects.map({$0._object!}), withName: name) { (isSuccess, error: NSError?) -> Void in
            if error != nil {
                print("[pinAllInBackground] ERROR: \(error!). For \(htObjects)", terminator: "\n")
            }
        }
    }

    override var description: String {
        return _object != nil ? "object: \(_object!)" : "object is nil"
    }

}