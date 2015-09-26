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
    var name: String {
        get { return self["name"] as! String }
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

    var _transactions: [Transaction]?

    convenience init(name: String) {
        self.init()
        self.userId = PFUser.currentUser()!.objectId!
    }

    func balance() -> NSDecimalNumber {
        var bal:NSDecimalNumber = 0

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
            }
        }

        return bal
    }

    func formattedBalance() -> String {
        let amount = balance()
        return String(format: "$%.02f", abs(amount.doubleValue))
    }

    // computed property
    // default is get
    var transactions: [Transaction] {
        get {
            guard _transactions != nil else {
                // load from DB
                print("loading transactions from local for account \(objectId)")
                _transactions = Transaction.findByAccountId(objectId!)
                return _transactions!
            }

            return _transactions!
        }
        set {
            _transactions = newValue
        }
    }

    func addTransaction(transaction: Transaction) {
        transaction._object?.saveEventually()
        transactions.append(transaction)
    }

    func removeTransaction(transaction: Transaction) {
        transaction._object?.deleteEventually()
        transactions = transactions.filter({ $0.uuid != transaction.uuid })
    }

    static func loadAll() {
        let user = PFUser.currentUser()!
        print("=====================\nUser: \(user)\n=====================", terminator: "\n")

        let localQuery = PFQuery(className: "Account").fromLocalDatastore()

        // TODO: move this out
        if user.objectId == nil {
//            user.save()
            do {
                try user.save()
                print("Success")
            } catch {
                print("An error occurred when saving user.")
            }
        }
//localQuery.findObjectsInBackgroundWithBlock

        localQuery.whereKey("userId", equalTo: user.objectId!)
        localQuery.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in

            if error != nil {
                print("Error loading accounts from Local: \(error)", terminator: "\n")
                return
            }

            _allAccounts = objects?.map({ Account(object: $0 ) })
            print("\n[local] accounts: \(objects)", terminator: "\n")

            if _allAccounts == nil || _allAccounts!.isEmpty {
                // load from server
                let remoteQuery = PFQuery(className: "Account")
                remoteQuery.whereKey("userId", equalTo: user.objectId!)
                remoteQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if let error = error {
                        print("Error loading accounts from Server: \(error)", terminator: "\n")
                        return
                    }

                    print("\n[server] accounts: \(objects)")
                    _allAccounts = objects?.map({ Account(object: $0 ) })

                    if _allAccounts!.isEmpty {
                        print("No account found for \(user). Creating Default Account", terminator: "\n")

                        let defaultAccount = Account(name: "Default Account")
                        let secondAccount  = Account(name: "Second Account")

                        defaultAccount.pinAndSaveEventuallyWithName("MyAccounts")
                        secondAccount.pinAndSaveEventuallyWithName("MyAccounts")
                        _allAccounts!.append(defaultAccount)
                        _allAccounts!.append(secondAccount)

                        print("accounts: \(_allAccounts!)", terminator: "\n")
                    } else {
                        Account.pinAllWithName(_allAccounts!, name: "MyAccounts")
                    }
                }
            }
        }
    }

    class func defaultAccount() -> Account? {
        return _allAccounts?.first
    }

    class func all() -> [Account]? {
        return _allAccounts;
    }

    class func findById(objectId: String) -> Account? {
        let record = _allAccounts?.filter({ (el) -> Bool in
            el.objectId == objectId
        }).first
        return record
    }

    // MARK: Printable
    override var description: String {
        let base = super.description
        return "uuid: \(uuid), userId: \(userId), name: \(name), icon: \(icon), base: \(base)"
    }
}

//extension Account: CustomStringConvertible {
//    override var description: String {
//        let base = super.description
//        return "userId: \(userId), name: \(name), icon: \(icon), base: \(base)"
//    }
//}