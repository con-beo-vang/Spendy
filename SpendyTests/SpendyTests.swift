//
//  SpendyTests.swift
//  SpendyTests
//
//  Created by Harley Trung on 9/13/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Quick
import Nimble

@testable import Spendy

class AccountSpec: QuickSpec {
  override func spec() {

    var account: Account!
    var toAccount: Account!

    beforeEach {
      //      account = Account(name: "Cash")
      account = Account(name: "Cash", startingBalance: 100.00)
      account.recomputeBalance()
    }

    describe("starting balance") {
      it("new account with starting balance 100.00") {
        expect(account.balance).to(beCloseTo(100.00, within: 0.0001))
      }
    }

    describe("#formattedBalance") {
      it("formatted balance with region US") {
        expect(account.formattedBalance()).to(equal("$100.00"))
      }
    }

    describe("#addTransaction") {

      context("expense kind") {
        beforeEach {
          let bookCategory = Category.findById("RXhPRosXiF")
          let transaction = Transaction(kind: Transaction.expenseKind, note: "", amount: 20, category: bookCategory, account: account, date: NSDate())
          account.addTransaction(transaction)
        }

        it("add new transaction, decrease balance") {
          expect(account.balance).to(beCloseTo(80.00, within: 0.0001))
        }
      }

      context("income kind") {
        beforeEach {
          let bonusCategory = Category.findById("sgk8obYqDy")
          let transaction = Transaction(kind: Transaction.incomeKind, note: "", amount: 50, category: bonusCategory, account: account, date: NSDate())
          account.addTransaction(transaction)
        }

        it("add new transaction, increase balance") {
          expect(account.balance).to(beCloseTo(150.00, within: 0.0001))
        }
      }

      fcontext("transfer kind") {
        beforeEach {
          // define toAccount
          toAccount = Account(name: "Salary")

          let transaction = Transaction(kind: Transaction.transferKind, note: "", amount: 30, category: Category.defaultTransferCategory(), account: account, date: NSDate())
          transaction.toAccount = toAccount
          account.addTransaction(transaction)
          toAccount.addTransaction(transaction)
        }

        it("add new transfer transaction, decrease balance in fromAccount") {
          expect(account.balance).to(beCloseTo(70.00, within: 0.0001))
        }

        it("add new transfer transaction, increase balance in toAccount") {
          expect(toAccount.balance).to(beCloseTo(30.00, within: 0.0001))
        }
      }
    }
  }
}

