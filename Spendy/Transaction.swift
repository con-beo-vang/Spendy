//
//  Transaction.swift
//  Spendy
//
//  Created by Harley Trung on 9/18/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Foundation
import Parse

/*
Schema:
    version (maybe)
    kind (income | expense | transfer)
    userID
    fromAccountId
    toAccountId (when kind is 'transfer')
    note
    amount
    categoryId
    date
    balanceSnapshot
*/

var _allTransactions: [Transaction]?

// newTransaction = Transaction(name: , amount: , ...)
// newTransaction.save()
// newTransaction.delete()
// account.addTransaction(newTransaction)
// account.removeTransaction(newTransaction)
class Transaction: HTObject {
    class var kinds: [String] {
        return [incomeKind, expenseKind, transferKind]
    }

    static let expenseKind: String = "Expense"
    static let incomeKind: String = "Income"
    static let transferKind: String = "Transfer"

    var balanceSnapshot: NSDecimalNumber {
        get {
            guard let am = self["balanceSnapshot"] as! NSNumber? else {
                return 0
            }
            return NSDecimalNumber(decimal: am.decimalValue)
        }
        set {
            let before = balanceSnapshot
            self["balanceSnapshot"] = newValue
            if before != balanceSnapshot {
                save()
            }
        }
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

    // only contains values if kind is Transfer
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
        let t = Transaction(kind: kind, note: note, amount: amount, category: category, account: fromAccount, date: date)
        if toAccount != nil {
            t.toAccount = toAccount
        }
        
        return t
    }

    func kindColor() -> UIColor {
        switch kind! {
        case Transaction.expenseKind:
            return Color.expenseColor
        case Transaction.incomeKind:
            return Color.incomeColor
        default:
            return Color.balanceColor
        }
    }

    // MARK: - relations
    var fromAccount: Account? {
        set {
            fromAccountId = newValue?.objectId
        }

        get {
            guard let fromAccountId = fromAccountId else {
                if let account = Account.defaultAccount() {
                    print("account missing in transaction: setting defaultAccount for it")
                    self.fromAccount = account
                    return account
                } else {
                    return nil
                }
            }
            return Account.findById(fromAccountId)
        }
    }
    
    var toAccount: Account? {
        set {
            toAccountId = newValue?.objectId
        }
        get {
            guard let toAccountId = toAccountId else {
                return nil
            }
            
            return Account.findById(toAccountId)
        }
    }

    var category: Category? {
        set {
            categoryId = newValue?.objectId
        }

        get {
            guard let categoryId = categoryId else {
                if let category = Category.defaultCategoryFor(kind!) {
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

    static var _currencyFormatter: NSNumberFormatter?
    static var currencyFormatter : NSNumberFormatter {
        guard _currencyFormatter != nil else {
            _currencyFormatter = NSNumberFormatter()
            _currencyFormatter!.numberStyle = .CurrencyStyle
            return _currencyFormatter!
        }

        return _currencyFormatter!
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
            // return String(format: "$%.02f", amount!.doubleValue)
            return Transaction.currencyFormatter.stringFromNumber(amount!)
        } else {
            return nil
        }
    }

    func formattedBalanceSnapshot() -> String? {

        return Transaction.currencyFormatter.stringFromNumber(balanceSnapshot)
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
        let queryWithFrom = PFQuery(className: "Transaction")
        queryWithFrom.whereKey("fromAccountId", equalTo: accountId)

        let queryWithTo = PFQuery(className: "Transaction")
        queryWithTo.whereKey("toAccountId", equalTo: accountId)

        let query = PFQuery.orQueryWithSubqueries([queryWithFrom, queryWithTo])
        query.orderByAscending("date")
        query.fromLocalDatastore()

        do {
            return try query.findObjects().map{Transaction(object: $0)}
        } catch {
            print("Error loading transaction for account: \(accountId)")
            return []
        }
    }

    class func add(element: Transaction) {
        element.save()
        element.fromAccount!.addTransaction(element)
    }

    override func delete() {
        _object?.unpinInBackground()
        _object?.deleteEventually()
        if let toAccount = toAccount {
            toAccount.detactTransaction(self)
        }
        if let fromAccount = fromAccount {
            fromAccount.detactTransaction(self)
        }
    }

    override var description: String {
        let base = super.description
        return "categoryId: \(categoryId), fromAccountId: \(fromAccountId), toAccountId: \(toAccountId), base: \(base)"
    }
}
