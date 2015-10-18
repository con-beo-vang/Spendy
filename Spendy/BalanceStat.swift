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

    var expenseTransactions: [RTransaction]?
    var groupedExpenseCategories: [String: NSDecimalNumber]?
    var expenseTotal: NSDecimalNumber?

    var incomeTransactions: [RTransaction]?
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
//                var transactions = objects.map { Transaction(object: $0) }
                var transactions = [RTransaction]()

                // start of hack
                // remove any invalid transactions
                // these transactions are caused by removing any old category or account
                // TODO: remove related transactions when removing an account
                var filtered = [RTransaction]()
//                for t in transactions {
//                    if t.fromAccount == nil || t.category == nil {
//                        t.delete()
//                    } else {
//                        filtered.append(t)
//                    }
//                }
                transactions = filtered
                // end of hack

                print("found \(transactions.count) objects: \(transactions)")

                self.expenseTransactions      = transactions.filter { $0.kind == CategoryType.Expense.rawValue }
                self.groupedExpenseCategories = self.groupTransactionsByCategory(self.expenseTransactions!)
                self.expenseTotal             = Array(self.groupedExpenseCategories!.values).reduce(0, combine: +)

                self.incomeTransactions       = transactions.filter { $0.kind == CategoryType.Income.rawValue }
                self.groupedIncomeCategories = self.groupTransactionsByCategory(self.incomeTransactions!)
                self.incomeTotal              = Array(self.groupedIncomeCategories!.values).reduce(0, combine: +)

                NSNotificationCenter.defaultCenter().postNotificationName(SPNotification.balanceStatsUpdated, object: nil)
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

    func groupTransactionsByCategory(transactions: [RTransaction]) -> [String: NSDecimalNumber] {
        var amountDict = [String: NSDecimalNumber]()

        for transaction in transactions {
            if let name = transaction.category?.name {
                if let amountDecimal = transaction.amountDecimal {
                    guard let soFar = amountDict[name] else {
                        amountDict[name] = amountDecimal
                        continue
                    }

                    amountDict[name] = soFar + amountDecimal
                }
            }
        }

        return amountDict
    }
}