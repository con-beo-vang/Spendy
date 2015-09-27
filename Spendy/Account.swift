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
            guard let am = self["startingBalance"] as! NSNumber? else {
                return 0
            }
            return NSDecimalNumber(decimal: am.decimalValue)
        }
        set { self["startingBalance"] = newValue }
    }

    var balance: NSDecimalNumber {
        get {
            guard let am = self["balance"] as! NSNumber? else {
                return 0
            }
            return NSDecimalNumber(decimal: am.decimalValue)
        }
        set { self["balance"] = newValue }
    }

    var _transactions: [Transaction]?

    convenience init(name: String) {
        self.init()
        self.name = name
        self.userId = PFUser.currentUser()!.objectId!
    }

    func recomputeBalance() {
        var bal = startingBalance

        // TODO: sort transactions
        for (_, t) in transactions.enumerate() {
            if let kind = t.kind {
                switch kind {
                case Transaction.expenseKind, Transaction.transferKind:
                    bal = bal.decimalNumberBySubtracting(t.amount!)
                case Transaction.incomeKind:
                    bal = bal.decimalNumberByAdding(t.amount!)
                default:
                    print("unexpected kind")
                }
                t.balanceSnapshot = bal
            }
        }

        self.balance = bal
    }

    func formattedBalance() -> String {
        return String(format: "$%.02f", abs(balance.doubleValue))
    }

    var transactions: [Transaction] {
        get {
            guard _transactions != nil else {
                // load from DB
                print("loading transactions from local for account \(objectId)")
                _transactions = Transaction.findByAccountId(objectId!)

                recomputeBalance()
                print("computed balance for \(_transactions?.count) items: \(balance)")
                return _transactions!
            }

            return _transactions!
        }
        set {
            _transactions = newValue
        }
    }

    func addTransaction(transaction: Transaction) {
        transaction.save()
        transactions.append(transaction)
        recomputeBalance()
    }

    func removeTransaction(transaction: Transaction) {
        // TODO: implement UNDO
        transaction._object?.deleteEventually()
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
                print("Success")
            } catch {
                print("An error occurred when saving user.")
            }
        }

        localQuery.whereKey("userId", equalTo: user.objectId!)
        localQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                print("Error loading accounts from Local: \(error)", terminator: "\n")
                return
            }

            _allAccounts = objects?.map({ Account(object: $0 ) })
            print("\n[local] accounts: \(objects)")

            if _allAccounts == nil || _allAccounts!.isEmpty {
                // load from server
                let remoteQuery = PFQuery(className: "Account")
                remoteQuery.whereKey("userId", equalTo: user.objectId!)
                remoteQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if let error = error {
                        print("Error loading accounts from Server: \(error)", terminator: "\n")
                        return
                    }

                    print("\n[server] accounts: \(objects!)")
                    _allAccounts = objects?.map({ Account(object: $0 ) })

                    if _allAccounts!.isEmpty {
                        print("No account found for \(user). Creating Default Account", terminator: "\n")

                        let defaultAccount = Account(name: "Default Account")
                        let secondAccount  = Account(name: "Second Account")

                        defaultAccount.pinAndSaveEventuallyWithName("MyAccounts")
                        secondAccount.pinAndSaveEventuallyWithName("MyAccounts")
                        _allAccounts!.append(defaultAccount)
                        _allAccounts!.append(secondAccount)

                        print("accounts: \(_allAccounts!)")
                    } else {
                        Account.pinAllWithName(_allAccounts!, name: "MyAccounts")
                    }
                }
            }
        }
    }

    // TODO: a different way to specify defaultAccount
    class func defaultAccount() -> Account? {
        return all()?.first
    }

    class func all() -> [Account]? {
        return _allAccounts;
    }

    class func findById(objectId: String) -> Account? {
        guard let all = all() else { return nil }

        return all.filter({ $0.objectId == objectId }).first
    }

    // MARK: Printable
    override var description: String {
        let base = super.description
        return "uuid: \(uuid), userId: \(userId), name: \(name), icon: \(icon), base: \(base)"
    }
}