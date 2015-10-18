//
//  HTRObject.swift
//  Spendy
//
//  Created by Harley Trung on 10/17/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import RealmSwift

class HTRObject: Object {
    dynamic var id: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }

    func isNew() -> Bool {
        return id == 0
    }

    func setIdIfNeeded(realm: Realm) {
        if id == 0 {
            if let last = realm.objects(self.dynamicType).last {
                print("last id: \(last.id)")
                id = last.id + 1
            } else {
                print("FIRST RECORD. SETTING ID = 1")
                id = 1
            }
        }
    }

    // TODO: test this
    func save() {
        let realm = try! Realm()
        setIdIfNeeded(realm)

        try! realm.write {
            realm.add(self, update: true)
        }
        print("saved id = \(self)")
    }

    func delete() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
