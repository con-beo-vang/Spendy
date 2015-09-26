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
        return [expenseKind, incomeKind, transferKind]
    }
    static let expenseKind: String = "expense"
    static let incomeKind: String = "income"
    static let transferKind: String = "transfer"

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

    func clone() -> Transaction {
        let t = Transaction(kind: kind, note: note, amount: amount, category: category, account: account, date: date)
        return t
    }

    func kindColor() -> UIColor {
        switch kind! {
        case Transaction.expenseKind:
            return UIColor(netHex: 0x3D8B37)
        case Transaction.incomeKind:
            return UIColor.redColor()
        default:
            return UIColor.cyanColor()
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

//    class func loadAll() {
//        print("\n\nloading fake data for Transactions", terminator: "\n")
//        let defaultCategory = Category.all()?.first
//        let defaultAccount = Account.all()?.first
//
//        // Initialize with fake transactions
//        let dateFormatter = Transaction.dateFormatter
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//        // TODO: load from and save to servers
//        _allTransactions =
//            [
//                Transaction(kind: Transaction.expenseKind, note: "Note 1", amount: 3.23, category: defaultCategory, account: defaultAccount, date: dateFormatter.dateFromString("2015-08-01")),
//                Transaction(kind: Transaction.expenseKind, note: "Note 2", amount: 4.23, category: defaultCategory, account: defaultAccount, date: dateFormatter.dateFromString("2015-08-02")),
//                Transaction(kind: Transaction.expenseKind, note: "Note 3", amount: 1.23, category: defaultCategory, account: defaultAccount, date: dateFormatter.dateFromString("2015-09-01")),
//                Transaction(kind: Transaction.expenseKind, note: "Note 4", amount: 2.23, category: defaultCategory, account: defaultAccount, date: dateFormatter.dateFromString("2015-09-02")),
//                Transaction(kind: Transaction.expenseKind, note: "Note 5", amount: 2.23, category: defaultCategory, account: defaultAccount, date: dateFormatter.dateFromString("2015-09-03"))
//            ]
////        println("post sort: \(_allTransactions!))")
//    }

    class func findByAccountId(accountId: String) -> [Transaction] {
        let query = PFQuery(className: "Transaction")
        query.fromLocalDatastore()
        query.whereKey("fromAccountId", equalTo: accountId)
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
