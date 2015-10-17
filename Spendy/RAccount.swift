//
//  RAccount.swift
//  Spendy
//
//  Created by Harley Trung on 10/17/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import RealmSwift

class RAccount: Object {
    dynamic var id = 0
    dynamic var name: String?
    dynamic var userId: String?
    dynamic var icon: String?
    dynamic var startingBalance: Int = 0
    dynamic var balance: Int = 0

    let transactions = List<RTransaction>()
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }

    static func bootstrap() {
        let realm = try! Realm()

        let rAccount = RAccount()
        // will always update record with id 1
        rAccount.id = 1
        rAccount.name = "Default"
        rAccount.balance = 100

        try! realm.write() {
            realm.add(rAccount, update: true)
        }
    }

    var formattedBalance: String {
        let bal = abs(balance)
        return Transaction.currencyFormatter.stringFromNumber(bal)!
    }

    static var all: [RAccount] {
        return Array(try! Realm().objects(RAccount))
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RAccount {
    func addTransaction(rTransaction: RTransaction) {
        transactions.append(rTransaction)
    }

    func removeTransaction(rTransaction: RTransaction) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(rTransaction)
        }
    }
}
