//
//  BalanceComputing.swift
//  Spendy
//
//  Created by Harley Trung on 10/18/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation
import RealmSwift

struct BalanceComputing {
    // recompute balance for an account
    // update balance snapshot in each transaction
    // upate total balance in account
    static func recompute(account: RAccount) {
        print("BalanceCompute.recompute(_) for \(account.id)")
        var bal = account.startingBalance

        // TODO: check if this actually works
        let transactions = account.transactions.sorted("date", ascending: true)

        let realm = try! Realm()
        try! realm.write {
            for t in transactions {
                switch t.kind! {
                case CategoryType.Income.rawValue:
                    bal += t.amount
                    t.balanceSnapshot = bal

                case CategoryType.Expense.rawValue:
                    bal -= t.amount
                    t.balanceSnapshot = bal

                case CategoryType.Transfer.rawValue:
                    if t.toAccount == account {
                        bal += t.amount
                        t.toBalanceSnapshot = bal
                    } else {
                        bal -= t.amount
                        t.balanceSnapshot = bal
                    }
                default:
                    print("Unexpected transaction kind \(t.kind) for transaction id \(t.id)")
                }
            }

            account.balance = bal
        }
    }
}