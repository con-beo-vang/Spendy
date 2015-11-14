//
//  Transaction.swift
//  Spendy
//
//  Created by Harley Trung on 10/17/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import RealmSwift

class Transaction: HTRObject {
    dynamic var kind: String? = nil
    dynamic var date: NSDate? = nil
    dynamic var note: String? = nil
    dynamic var amount: Int = 0
    dynamic var toAccount: Account? = nil
    dynamic var fromAccount: Account? = nil
    dynamic var category: Category? = nil

    dynamic var balanceSnapshot: Int = 0
    dynamic var toBalanceSnapshot: Int = 0

    static var dateFormatter = NSDateFormatter()

    convenience init(kind: String, note: String?, amountDecimal: NSDecimalNumber, category: Category, account: Account, date: NSDate) {
        self.init()

        self.kind = kind
        self.note = note
        self.amountDecimal = amountDecimal
        self.category = category
        self.date = date
        self.fromAccount = account
    }

    // store in the DB the amount in cent
    // interface via amountDecimal which is dollar
    var amountDecimal: NSDecimalNumber? {
        get { return intToDecimal(amount) }
        set { amount = decimalToInt(newValue) }
    }

    func intToDecimal(val: Int) -> NSDecimalNumber {
        return NSDecimalNumber(integer: val) * 0.01
    }

    func decimalToInt(newValue: NSDecimalNumber?) -> Int {
        guard let val = newValue where val != NSDecimalNumber.notANumber() else {
            return 0
        }

        return (val * 100).integerValue
    }

    func update(updateFunction: (transaction: Transaction) -> Void) {
        if isNew() {
            updateFunction(transaction: self)
        } else {
            let realm = try! Realm()
            try! realm.write {
                updateFunction(transaction: self)
            }
        }
    }

    override static func ignoredProperties() -> [String] {
        return ["amountDecimal"]
    }

    func clone() -> Transaction {
        let ret         = Transaction()
        ret.kind        = kind
        ret.note        = note
        ret.amount      = amount
        ret.date        = date
        ret.fromAccount = fromAccount
        ret.toAccount   = toAccount
        ret.category    = category
        return ret
    }

    func isTransfer() -> Bool {
        guard let kind = kind else { return false }
        return kind == CategoryType.Transfer.rawValue
    }

    override func save() {
        let realm = try! Realm()

        try! realm.write {
            self.setIdIfNeeded(realm)

            if let fromAccount = self.fromAccount {
                let siblings = fromAccount.transactions
                if nil == siblings.filter({$0.id == self.id}).first {
                    fromAccount.transactions.append(self)
                }
            }

            if let toAccount = self.toAccount {
                let siblings = toAccount.transactions
                if nil == siblings.filter({$0.id == self.id}).first {
                    toAccount.transactions.append(self)
                }
            }


        }

        if let toAccount = self.toAccount {
            BalanceComputing.recompute(toAccount)
        }

        if let fromAccount = self.fromAccount {
            BalanceComputing.recompute(fromAccount)
        }
    }

    func remove() {
        // cache pointers before removal
        let toAccount = self.toAccount
        let fromAccount = self.fromAccount

        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }

        if toAccount != nil {
            BalanceComputing.recompute(toAccount!)
        }

        if fromAccount != nil {
            BalanceComputing.recompute(fromAccount!)
        }
    }
}

// MARK: - computed properties
extension Transaction {
    var categoryName: String? {
        return category?.name
    }

    var categoryIcon: String? {
        return category?.icon
    }

    func formattedAmount() -> String? {
        return Currency.currencyFormatter.stringFromNumber(amountDecimal!)
    }

    func formattedToBalanceSnapshot() -> String? {
        return Currency.currencyFormatter.stringFromNumber(intToDecimal(toBalanceSnapshot))
    }

    func formattedBalanceSnapshot() -> String? {
        return Currency.currencyFormatter.stringFromNumber(intToDecimal(balanceSnapshot))
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
                Transaction.dateFormatter.dateStyle = dateStyle!
            }

            if dateFormat != nil {
                Transaction.dateFormatter.dateFormat = dateFormat!
            }

            return Transaction.dateFormatter.stringFromDate(date)
        } else {
            return nil
        }
    }
}