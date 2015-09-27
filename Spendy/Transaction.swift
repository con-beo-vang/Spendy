//
//  Transaction.swift
//  Spendy
//
//  Created by Harley Trung on 9/18/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Foundation
import Parse

/////////////////////////////////////////
//Schema:
//- kind (income | expense | transfer)
//- user_id
//- from_account
//- to_account (when type is ‘transfer’)
//- note
//- amount
//- category_id
//- date
/////////////////////////////////////////

var _allTransactions: [Transaction]?

// newTransaction = Transaction(name: , amount: )
// newTransaction.save()
// newTransaction.delete()
// account.addTransaction(newTransaction)
// account.removeTransaction(newTransaction)
class Transaction: HTObject {
    class var kinds: [String] {
        return [incomeKind, expenseKind, transferKind]
    }
    static let expenseKind: String = "expense"
    static let incomeKind: String = "income"
    static let transferKind: String = "transfer"

    var balanceSnapshot: NSDecimalNumber {
        get {
            guard let am = self["balanceSnapshot"] as! NSNumber? else {
                return 0
            }
            return NSDecimalNumber(decimal: am.decimalValue)
        }
        set { self["balanceSnapshot"] = newValue }
    }

    // transaction.note =>
    // transaction.note = "blah"
    var note: String? {
        get { return self["note"] as! String? }
        set { self["note"] = newValue }
    }

    // transaction.amount = 12.23
    // transaction.amount => json --> string --> cast decimal
    var amount: NSDecimalNumber? {
        get {
            guard let am = self["amount"] as! NSNumber? else { return nil }
            return NSDecimalNumber(decimal: am.decimalValue)
        }
        set { self["amount"] = newValue }
    }

    var fromAccountId: String? {
        get { return self["fromAccountId"] as! String? }
        set { self["fromAccountId"] = newValue }
    }

    var toAccountId: String? {
        get { return self["toAccountId"] as! String? }
        set { self["toAccountId"] = newValue }
    }

    var date: NSDate? {
        get { return self["date"] as! NSDate? }
        set { self["date"] = newValue }
    }

    var kind: String? {
        get { return self["kind"] as! String? }
        set { self["kind"] = newValue }
    }

    var categoryId: String? {
        get { return self["categoryId"] as! String? }
        set { self["categoryId"] = newValue }
    }
    
    convenience init(kind: String?, note: String?, amount: NSDecimalNumber?, category: Category?, account: Account?, date: NSDate?) {
        self.init()

        self.kind = kind
        self.note = note
        self.amount = amount
        self.categoryId = category?.objectId
        self.fromAccountId = account?.objectId
        self.date = date
    }

    // TODO: support validation errors
    override func isValid() -> Bool {
        guard super.isValid() else { return false }
        guard fromAccountId != nil else { return false }
        guard !fromAccountId!.isEmpty else { return false }

        return true
    }

    func clone() -> Transaction {
        let t = Transaction(kind: kind, note: note, amount: amount, category: category, account: account, date: date)
        return t
    }

    func kindColor() -> UIColor {
        switch kind! {
        case Transaction.expenseKind:
            return UIColor.redColor()
        case Transaction.incomeKind:
            return UIColor(netHex: 0x3D8B37)
        default:
            return UIColor.blueColor()
        }
    }

    // MARK: - relations
    var account: Account? {
        set {
            fromAccountId = newValue?.objectId
        }

        get {
            guard let fromAccountId = fromAccountId else {
                if let account = Account.defaultAccount() {
                    print("account missing in transaction: setting defaultAccount for it")
                    self.account = account
                    return account
                } else {
                    return nil
                }
            }
            return Account.findById(fromAccountId)
        }
    }

    var category: Category? {
        set {
            categoryId = newValue?.objectId
        }

        get {
            guard let categoryId = categoryId else {
                if let category = Category.defaultCategory() {
                    print("category missing in transaction: setting defaultCategory for it")
                    self.category = category
                    return category
                } else {
                    return nil
                }
            }

            return Category.findById(categoryId)
        }
    }
    
    // MARK: - date formatter
    static var dateFormatter = NSDateFormatter()
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

    static var currencyFormatter = NSNumberFormatter()

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

    // MARK: - unused
    static var transactions: [PFObject]?
    static func findAll(completion: (transactions: [PFObject]?, error: NSError?) -> ()) {
        let query = PFQuery(className: "Transaction")
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error != nil {
                print("Error loading transactions", terminator: "\n")
                completion(transactions: nil, error: error)
            } else {
                self.transactions = results 
                completion(transactions: self.transactions, error: error)
            }
        }
    }

    // MARK: - view helpers
    func formattedAmount() -> String? {
        if amount != nil {
            return String(format: "$%.02f", amount!.doubleValue)
        } else {
            return nil
        }
    }

    func formattedBalanceSnapshot() -> String? {
        let formatter = Transaction.currencyFormatter
        formatter.numberStyle = .CurrencyStyle

        return formatter.stringFromNumber(balanceSnapshot)
    }

    // MARK: - Utilities
    class func all() -> [Transaction]? {
        return _allTransactions
    }

    class func dictGroupedByMonth(trans: [Transaction]) -> [String: [Transaction]] {
        var dict = [String:[Transaction]]()
        for el in trans {
            let key = el.monthHeader() ?? "Unknown"
            dict[key] = (dict[key] ?? []) + [el]
        }
        return dict
    }

    class func listGroupedByMonth(trans: [Transaction]) -> [[Transaction]] {
        let grouped = dictGroupedByMonth(trans)
        var list: [[Transaction]] = []

        for (key, _) in grouped {
            var g:[Transaction] = grouped[key]!
            // sort values in each bucket, newest first
            g.sortInPlace({
                guard $1.date != nil && $0.date != nil else { return true }
                return $1.date! < $0.date!
            })
            list.append(g)
        }

        // sort by month
        list.sortInPlace({ $1[0].date! < $0[0].date! })

        return list
    }

    class func findByAccountId(accountId: String) -> [Transaction] {
        let query = PFQuery(className: "Transaction")
        query.fromLocalDatastore()
        query.whereKey("fromAccountId", equalTo: accountId)
        query.orderByAscending("date")

        do {
            return try query.findObjects().map{Transaction(object: $0)}
        } catch {
            print("Error loading transaction for account: \(accountId)")
            return []
        }
    }

    class func add(element: Transaction) {
        element.save()
        element.account!.addTransaction(element)
    }

    override var description: String {
        let base = super.description
        return "categoryId: \(categoryId), fromAccountId: \(fromAccountId), toAccountId: \(toAccountId), base: \(base)"
    }
}
