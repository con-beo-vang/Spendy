//
//  TransactionSpec.swift
//  Spendy
//
//  Created by Dave Vo on 10/21/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Quick
import Nimble

@testable import Spendy

class TransactionSpec: QuickSpec {
    
    override func spec() {
        
        describe("convert amount") {
            let transaction = Transaction()
            
            context("from Int to Decimal") {
                it("1525 is converted to 15.25") {
                    expect(transaction.intToDecimal(1525)).to(equal(15.25))
                }
            }
            
            context("from Decimal to Int") {
                it("12 is converted to 1200") {
                    expect(transaction.decimalToInt(12)).to(equal(1200))
                }
            }
        }
        
        describe("#addTransaction") {
            var account: Account!
            
            beforeEach {
                account = SpendyTest.createAccount()
            }
            
            context("transaction is an expense") {
                var transaction: Transaction!
                
                beforeEach {
                    let defaultCategory = Category.defaultCategoryFor(CategoryType.Expense)
                    transaction = Transaction(kind: CategoryType.Expense.rawValue, note: "", amountDecimal: 20, category: defaultCategory, account: account, date: NSDate())
                    transaction.save()
                }
                
                it("adds new transaction, decrease balance") {
                    expect(account.balance).to(equal(8000))
                }
                
                afterEach {
                    transaction.delete()
                }
            }
            
            context("transaction is an income") {
                var transaction: Transaction!
                
                beforeEach {
                    let defaultCategory = Category.defaultCategoryFor(CategoryType.Income)
                    transaction = Transaction(kind: CategoryType.Income.rawValue, note: "", amountDecimal: 50, category: defaultCategory, account: account, date: NSDate())
                    transaction.save()
                }
                
                
                it("adds new transaction, increase balance") {
                    expect(account.balance).to(equal(15000))
                }
                
                afterEach {
                    transaction.delete()
                }
            }
            
            context("transaction is a transference") {
                var transaction: Transaction!
                var toAccount: Account!
                
                beforeEach {
                    toAccount = SpendyTest.createAccount()
                    
                    let defaultCategory = Category.defaultCategoryFor(CategoryType.Transfer)
                    
                    transaction = Transaction(kind: CategoryType.Transfer.rawValue, note: "", amountDecimal: 50, category: defaultCategory, account: account, date: NSDate())
                    transaction.toAccount = toAccount
                    transaction.save()
                }
                
                it("adds new transfer transaction, decrease balance in fromAccount") {
                    expect(account.balance).to(equal(5000))
                }
                
                it("adds new transfer transaction, increase balance in toAccount") {
                    expect(toAccount.balance).to(equal(15000))
                }
                
                afterEach {
                    transaction.delete()
                    SpendyTest.deleteAccount(toAccount)
                }
            }
            
            afterEach {
                SpendyTest.deleteAccount(account)
            }
        }
    }
}