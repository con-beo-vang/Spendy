//
//  BalanceStat.swift
//  Spendy
//
//  Created by Harley Trung on 10/5/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation
import RealmSwift

// TODO: save to DB so that it's faster
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

        let realm = try! Realm()

        // TODO restrict to userId
        let transactions = realm.objects(RTransaction).filter("date >= %@ AND date <= %@", from, to)

        print("found \(transactions.count) transactions from \(from) to \(to)")

        self.expenseTransactions      = transactions.filter { $0.kind == CategoryType.Expense.rawValue }
        self.groupedExpenseCategories = self.groupTransactionsByCategory(self.expenseTransactions!)
        self.expenseTotal             = Array(self.groupedExpenseCategories!.values).reduce(0, combine: +)

        self.incomeTransactions       = transactions.filter { $0.kind == CategoryType.Income.rawValue }
        self.groupedIncomeCategories = self.groupTransactionsByCategory(self.incomeTransactions!)
        self.incomeTotal              = Array(self.groupedIncomeCategories!.values).reduce(0, combine: +)

        NSNotificationCenter.defaultCenter().postNotificationName(SPNotification.balanceStatsUpdated, object: nil)
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