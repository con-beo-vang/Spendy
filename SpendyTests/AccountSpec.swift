//
//  AccountSpec.swift
//  Spendy
//
//  Created by Dave Vo on 10/21/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Quick
import Nimble

@testable import Spendy

class AccountSpec: QuickSpec {
    
    override func spec() {
        
        var account: Account!
        
        beforeEach {
            account = SpendyTest.createAccount()
        }
        
        describe("starting balance") {
            it("new account with starting balance 10000") {
                expect(account.startingBalance).to(equal(10000))
            }
            
            it("new account with starting balance decimal 100.00") {
                expect(account.startingBalanceDecimal).to(equal(100.00))
            }
        }
        
        describe("#formattedBalance") {
            it("formatted starting balance with region US") {
                expect(account.formattedStartingaBalance).to(equal("$100.00"))
            }
        }
        
        describe("#formattedBalance") {
            it("formatted balance with region US") {
                expect(account.formattedBalance).to(equal("$100.00"))
            }
        }
        
        
        
        describe("#all") {
            it("number of accounts is 3") {
                expect(Account.all.count).to(equal(3))
            }
        }
        
        afterEach {
            SpendyTest.deleteAcocunt(account)
        }
    }
}