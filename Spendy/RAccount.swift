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
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }

    convenience init(name: String?, startingBalanceDecimal: NSDecimalNumber) {
        self.init()
        
        self.name = name
        startingBalance = (startingBalanceDecimal * 100).integerValue
    }

    static func bootstrap() {
        let rAccount = RAccount()
        // will always update record with id 1
        rAccount.id = 1
        rAccount.name = "Default"
        rAccount.balance = 100

        rAccount.save()
    }

    var formattedBalance: String {
        let bal = abs(balance)
        return Currency.currencyFormatter.stringFromNumber(bal)!
    }

    static var all: [RAccount] {
        return Array(try! Realm().objects(RAccount))
    }

    static func defaultAccount() -> RAccount {
        let account = try! Realm().objects(RAccount).first
        return account!
    }

    // TODO: implement
    static func nonDefaultAccount() -> RAccount {
        let account = try! Realm().objects(RAccount).first
        return account!
    }

    func recomputeBalance() {
        // TODO: implement
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
