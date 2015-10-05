//
//  BalanceStat.swift
//  Spendy
//
//  Created by Harley Trung on 10/5/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation
import Parse

class BalanceStat {
    var from: NSDate
    var to:NSDate

    var expenseTransactions: [Transaction]?
    var groupedExpenseCategories: [String: NSDecimalNumber]?
    var expenseTotal: NSDecimalNumber?

    init(from: NSDate, to: NSDate) {
        self.from = from
        self.to   = to

        // load expenses
        // initially load all
        let query = PFQuery(className: "Transaction")
        // query.fromLocalDatastore()

        query.whereKey("kind", equalTo: Transaction.expenseKind)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                self.expenseTransactions = objects.map { Transaction(object: $0) }
                self.groupedExpenseCategories = self.groupTransactionsByCategory(self.expenseTransactions!)
                self.expenseTotal = Array(self.groupedExpenseCategories!.values).reduce(0, combine: +)
                print("found \(objects)")

                NSNotificationCenter.defaultCenter().postNotificationName(SPNotification.groupedStatsOnExpenseCategories, object: nil)
            } else {
                print("[BalanceStat] Error: \(error)")
            }
        }
    }

    func groupTransactionsByCategory(transactions: [Transaction]) -> [String: NSDecimalNumber] {
        var amountDict = [String: NSDecimalNumber]()

        for transaction in transactions {
            if let name = transaction.category?.name {
                if let amount = transaction.amount {
                    guard let soFar = amountDict[name] else {
                        amountDict[name] = amount
                        continue
                    }

                    amountDict[name] = soFar + amount
                }
            }
        }

        return amountDict
    }
}