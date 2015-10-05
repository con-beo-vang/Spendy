//
//  Account.swift
//  Spendy
//
//  Created by Harley Trung on 9/18/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Foundation
import Parse

var _allAccounts: [Account]?

class Account: HTObject {
    var name: String? {
        get { return self["name"] as! String? }
        set { self["name"] = newValue }
    }

    var userId: String {
        get { return self["userId"] as! String }
        set { self["userId"] = newValue }
    }

    var icon: String? {
        get { return self["icon"] as! String? }
        set { self["icon"] = newValue }
    }

    var startingBalance: NSDecimalNumber {
        get {
            guard let am = self["startingBalance"] as! NSNumber? else { return 0 }
            return NSDecimalNumber(decimal: am.decimalValue)
        }
        set { self["startingBalance"] = newValue }
    }

    var balance: NSDecimalNumber {
        get {
            guard let am = self["balance"] as! NSNumber? else { return 0 }
            return NSDecimalNumber(decimal: am.decimalValue)
        }
        set {
            let before = balance
            self["balance"] = newValue
            if before != balance {
                save()
            }
        }
    }
    
    func createdAt() -> NSDate {
        return (_object?.createdAt)!
    }

    static var forceLoadFromRemote = false
    var _transactions: [Transaction]?

    convenience init(name: String, startingBalance: NSDecimalNumber = 0) {
        self.init()
        self.name = name
        self.startingBalance = startingBalance
        self.userId = PFUser.currentUser()!.objectId!
    }

    func recomputeBalance() {
        var bal = NSDecimalNumber(double: startingBalance.doubleValue)

        // TODO: sort transactions
        for (_, t) in transactions.enumerate() {
            guard let kind = t.kind else { print("Unexpected nil kind in \(t)"); continue }

            switch kind {
            case Transaction.transferKind:
                if t.toAccountId == self.objectId {
                    // this is the transfer transaction displayed under destination account
                    bal = bal.decimalNumberByAdding(t.amount!)
                } else {
                    bal = bal.decimalNumberBySubtracting(t.amount!)
                }

            case Transaction.expenseKind:
                bal = bal.decimalNumberBySubtracting(t.amount!)
                
            case Transaction.incomeKind:
                bal = bal.decimalNumberByAdding(t.amount!)
                
            default:
                print("unexpected kind: \(kind)")
            }

            if t.toAccountId == self.objectId {
                // this is the transfer transaction displayed under destination account
                if bal != t.toBalanceSnapshot {
                    t.toBalanceSnapshot = bal
                }
            } else {
                if bal != t.balanceSnapshot {
                    t.balanceSnapshot = bal
                }
            }
        }

        if bal != balance {
            self.balance = bal
        }
    }

    func formattedBalance() -> String {
        let bal = NSDecimalNumber(double: abs(balance.doubleValue))
        return Transaction.currencyFormatter.stringFromNumber(bal)!
    }

    var transactions: [Transaction] {
        get {
            guard _transactions != nil else {
                _transactions = []

                // load from DB
                // TODO: optimize
                print("loading transactions from local for account \(objectId!)")
                 // _transactions = Transaction.findByAccountId(objectId!)
                // recomputeBalance()
//                print("computed balance for \(_transactions!.count) items. Balance \(balance)")
//                return _transactions!
                Transaction.loadByAccount(self)
                return _transactions!
            }

            return _transactions!
        }
        set {
            _transactions = newValue
        }
    }

    func addTransaction(transaction: Transaction) {
        if transaction.isNew() {
            // expect transaction to have been saved
            // only save if it's a new record
            transaction.save()
        }
        transactions.append(transaction)
        recomputeBalance()
    }

    func removeTransaction(transaction: Transaction) {
        // TODO: implement UNDO
        transaction.delete()
    }

    // called by Transaction:delete method
    func detactTransaction(transaction: Transaction) {
        transactions = transactions.filter({ $0.uuid != transaction.uuid })
        recomputeBalance()
    }

    static func loadAll() {
        let user = PFUser.currentUser()!
        print("=====================\nUser: \(user)\n=====================")

        let localQuery = PFQuery(className: "Account").fromLocalDatastore()

        // TODO: move this out
        if user.objectId == nil {
            do {
                try user.save()
                print("Just saved user")
            } catch let error {
                print("An error occurred when saving user: \(error)")
            }
        }

        localQuery.whereKey("userId", equalTo: user.objectId!)
        localQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            guard let objects = objects where error == nil else {
                print("Error loading accounts from Local. Error: \(error)")
                return
            }

            _allAccounts = objects.map({ Account(object: $0 ) })
            print("\n[local] loaded \(objects.count) accounts")

            if _allAccounts!.isEmpty {
                // load from server
                let remoteQuery = PFQuery(className: "Account")
                remoteQuery.whereKey("userId", equalTo: user.objectId!)
                remoteQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if let error = error {
                        print("Error loading accounts from Server: \(error)")
                        return
                    }

                    print("\n[server] loaded \(objects!.count) accounts")
                    _allAccounts = objects?.map({ Account(object: $0 ) })

                    if _allAccounts!.isEmpty {
                        print("No account found for \(user). Creating default accounts:")

                        let defaultAccount = Account(name: "Primary Account")
                        let secondAccount  = Account(name: "Bank")

                        defaultAccount.pinAndSaveEventuallyWithName("MyAccounts")
                        secondAccount.pinAndSaveEventuallyWithName("MyAccounts")
                        _allAccounts!.append(defaultAccount)
                        _allAccounts!.append(secondAccount)

                        print("accounts: \(_allAccounts!)")
                    } else {
                        for account in _allAccounts! {
                            account.recomputeBalance()
                        }
                        Account.pinAllWithName(_allAccounts!, name: "MyAccounts")
                    }
                }
            } else {
                for account in _allAccounts! {
                    account.recomputeBalance()
                }
            }
        }
    }

    class func defaultAccount() -> Account? {
        if let existing = PFUser.currentUser()!.objectForKey("defaultAccount") as! PFObject? {
            return Account(object: existing)
        } else {
            return all.first
        }
    }

    // used for a transaction's To Account field
    class func nonDefaultAccount() -> Account? {
        if let defaultAcc = defaultAccount() {
            return all.filter({$0 != defaultAcc}).first
        } else {
            return nil
        }
    }

    class var all: [Account] {
        if _allAccounts == nil {
            let user = PFUser.currentUser()!

            let query = PFQuery(className: "Account")
            query.whereKey("userId", equalTo: user.objectId!)

            if !forceLoadFromRemote {
                query.fromLocalDatastore()
            }
            let objects = try! query.findObjects()
            _allAccounts = objects.map({ Account(object: $0) })
        }

        return _allAccounts!
    }

    class func findById(objectId: String) -> Account? {
        return all.filter({ $0.objectId == objectId }).first
    }

    // MARK: Printable
    override var description: String {
        let base = super.description
        return "uuid: \(uuid), userId: \(userId), name: \(name), icon: \(icon), base: \(base)"
    }

    class func create(account: Account) {
        account.save()
        _allAccounts!.append(account)
    }

    class func delete(account: Account) {
        account._object?.deleteEventually()
        _allAccounts = _allAccounts?.filter({ $0.uuid != account.uuid })
    }
}