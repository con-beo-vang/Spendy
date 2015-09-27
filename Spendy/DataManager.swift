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
    class func setupDefaultData(removeLocalData: Bool = false) {
        if removeLocalData {
            print("\n**Remove all local data**\n")
            // There is a bug with Parse right now and this doesn't not run successfully in Swift 2 for now
            try! PFObject.unpinAllObjects()
            // unused:
//            PFObject.unpinAllObjectsInBackgroundWithName("MyAccounts")
//            PFObject.unpinAllObjectsInBckgroundWithName("MyCategories")
        }

        // Load all categories from local
        // If categories are empty from local, load from server
        Category.loadAll()

        // Load user's accounts
        // If accounts are empty,load from server
        // If accounts are still empty, create new ones, save to server
        Account.loadAll()

        // TODO: load other settings
    }
}