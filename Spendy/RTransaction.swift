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

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }

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

//        let realm = try! Realm()
//
//        try! realm.write {
//            if item.isNew() {
//                realm.add(item)
//            } else {
//                realm.add(item, update: true)
//            }
//        }
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
        return "TODO: category name"
    }

    var categoryIcon: String? {
        return "TODO: category icon"
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