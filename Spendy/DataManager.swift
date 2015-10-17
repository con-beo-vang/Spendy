//
//  DataManager.swift
//  Spendy
//
//  Created by Harley Trung on 9/22/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager {
    static let version = "1.3"

    class func setupDefaultData(removeLocalData: Bool = false) {
        RAccount.bootstrap()
        RCategory.bootstrap()
    }
}