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


// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
