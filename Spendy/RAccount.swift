//
//  RAccount.swift
//  Spendy
//
//  Created by Harley Trung on 10/17/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import RealmSwift

class RAccount: HTRObject {
    dynamic var name: String?
    dynamic var userId: String?
    dynamic var icon: String?
    dynamic var startingBalance: Int = 0
    dynamic var balance: Int = 0
    dynamic var createdAt = NSDate(timeIntervalSince1970: 1)

    let transactions = List<RTransaction>()

    var sortedTransactions: [RTransaction] {
        return Array(transactions.sorted("date", ascending: false))
    }

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }

    convenience init(name: String?, startingBalanceDecimal: NSDecimalNumber) {
        self.init()
        
        self.name = name
        startingBalance = (startingBalanceDecimal * 100).integerValue
    }

    var startingBalanceDecimal: NSDecimalNumber {
        return NSDecimalNumber(integer: startingBalance) * 0.01
    }

    static func bootstrap() {
        // only bootstrap if we have 0 account
        let realm = try! Realm()

        let accounts = realm.objects(RAccount)

        if accounts.count == 0 {
            let primary = RAccount(name: "Primary", startingBalanceDecimal: 0)
            // will always update record with id 1
            primary.id = 1
            primary.save()

            let secondary = RAccount(name: "Secondary", startingBalanceDecimal: 0)
            secondary.id = 2
            secondary.save()
        }
    }

    var formattedBalance: String {
        let bal = NSDecimalNumber(integer: abs(balance)) * 0.01
        return Currency.currencyFormatter.stringFromNumber(bal)!
    }

    static var all: [RAccount] {
        return Array(try! Realm().objects(RAccount))
    }

    static func defaultAccount() -> RAccount {
        // TODO: use user's defaultAccount setting
        let account = try! Realm().objects(RAccount).first
        return account!
    }

    // TODO: implement
    static func nonDefaultAccount() -> RAccount {
        return all.filter({$0.id != defaultAccount().id}).first!
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
