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

    var incomeTransactions: [Transaction]?
    var groupedIncomeCategories: [String: NSDecimalNumber]?
    var incomeTotal: NSDecimalNumber?

    init(from: NSDate, to: NSDate) {
        self.from = from
        self.to   = to

        print("Stats from \(from) to \(to)")

        // load expenses
        // initially load all
        let query = PFQuery(className: "Transaction")
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        query.whereKey("date", greaterThanOrEqualTo: from)
        query.whereKey("date", lessThanOrEqualTo: to)
        // query.fromLocalDatastore()

        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                let transactions = objects.map { Transaction(object: $0) }

                self.expenseTransactions      = transactions.filter { $0.kind == Transaction.expenseKind }
                self.groupedExpenseCategories = self.groupTransactionsByCategory(self.expenseTransactions!)
                self.expenseTotal             = Array(self.groupedExpenseCategories!.values).reduce(0, combine: +)

                self.incomeTransactions       = transactions.filter { $0.kind == Transaction.incomeKind }
                self.groupedIncomeCategories = self.groupTransactionsByCategory(self.incomeTransactions!)
                self.incomeTotal              = Array(self.groupedIncomeCategories!.values).reduce(0, combine: +)

                NSNotificationCenter.defaultCenter().postNotificationName(SPNotification.groupedStatsOnExpenseCategories, object: nil)
            } else {
                print("[BalanceStat] Error: \(error)")
            }
        }
    }

    var balanceTotal:NSDecimalNumber? {
        guard let expenseTotal = expenseTotal,
            incomeTotal  = incomeTotal else {
                return nil
        }

        return incomeTotal - expenseTotal
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