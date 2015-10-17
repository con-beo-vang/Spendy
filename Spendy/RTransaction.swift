//
//  RTransaction.swift
//  Spendy
//
//  Created by Harley Trung on 10/17/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import RealmSwift

class RTransaction: HTRObject {
    dynamic var kind: String? = nil
    dynamic var date: NSDate? = nil
    dynamic var note: String? = nil
    dynamic var amount: Int = 0
    dynamic var toAccount: RAccount? = nil
    dynamic var fromAccount: RAccount? = nil
    dynamic var category: RCategory? = nil

    dynamic var balanceSnapshot: Int = 0
    dynamic var toBalanceSnapshot: Int = 0

    static var dateFormatter = NSDateFormatter()

    var amountDecimal: NSDecimalNumber? {
        get {
            return NSDecimalNumber(integer: amount) * 0.01
        }
        set {
            guard let val = newValue where val != NSDecimalNumber.notANumber() else {
                amount = 0
                return
            }

            amount = (val * 100).integerValue
        }
    }

    override static func ignoredProperties() -> [String] {
        return ["amountDecimal"]
    }

    func clone() -> RTransaction {
        let ret = RTransaction()
        // TODO: clone properties
        return ret
    }

    func isTransfer() -> Bool {
        guard let kind = kind else { return false }
        return kind == CategoryType.Transfer.rawValue
    }

    // TODO: create if id is 0, otherwise update
    static func addOrUpdate(item: RTransaction) {
        item.save()
    }
}

extension RTransaction {
    static func listGroupedByMonth(rTransactions: [RTransaction]) -> [[RTransaction]] {
        return [rTransactions]
    }
}

// MARK: - computed properties
extension RTransaction {
    var categoryName: String? {
        return category?.name
    }

    var categoryIcon: String? {
        return category?.icon
    }

    func formattedAmount() -> String? {
        return Transaction.currencyFormatter.stringFromNumber(amount)
    }

    func formattedToBalanceSnapshot() -> String? {
        return Transaction.currencyFormatter.stringFromNumber(toBalanceSnapshot)
    }

    func formattedBalanceSnapshot() -> String? {
        return Transaction.currencyFormatter.stringFromNumber(balanceSnapshot)
    }

        // Ex: September 21, 2015
    func dateOnly() -> String? {
        return dateToString(NSDateFormatterStyle.LongStyle)
    }

    // Ex: Thursday, 7 AM
    func dayAndTime() -> String? {
        return dateToString(dateFormat: "EEEE, h a")
    }

    func monthHeader() -> String? {
        return dateToString(dateFormat: "MMMM YYYY")
    }

    // TODO: just use DateUtilities
    func dateToString(dateStyle: NSDateFormatterStyle? = nil, dateFormat: String? = nil) -> String? {
        if let date = date {
            if dateStyle != nil {
                RTransaction.dateFormatter.dateStyle = dateStyle!
            }

            if dateFormat != nil {
                RTransaction.dateFormatter.dateFormat = dateFormat!
            }

            return RTransaction.dateFormatter.stringFromDate(date)
        } else {
            return nil
        }
    }
}