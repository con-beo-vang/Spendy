//
//  DataManager.swift
//  Spendy
//
//  Created by Harley Trung on 9/22/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Foundation
import Parse

class DataManager {
    static let version = "1.3"

    class func setupDefaultData(removeLocalData: Bool = false) {
        if removeLocalData {
            print("\n**Remove all local data**\n")
            // There is a bug with Parse right now and this doesn't not run successfully in Swift 2
            // TODO: update to the latest Parse
            try! PFObject.unpinAllObjects()
        }

        if removeLocalData || User.isDataVersionOutOfDate() {
            print("Data not up to date. Loading from remote")
            Category.loadAllFrom(local: false)
            Account.loadAllFrom(local: false)

            if User.isDataVersionOutOfDate() {
                User.current()?.updateDataVersion(version)
            }
        } else {
            // Load all categories from local
            // If categories are empty from local, load from server
            Category.loadAllFrom(local: true)

            // Load user's accounts
            // If accounts are empty,load from server
            // If accounts are still empty, create new ones, save to server
            Account.loadAllFrom(local: true)
        }

        // TODO: load other settings
    }
}