//
//  SpendyTests.swift
//  SpendyTests
//
//  Created by Harley Trung on 9/13/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

@testable import Spendy

class SpendyTest {
    
    static func createAccount() -> Account {
        let account = Account(name: "Cash", startingBalanceDecimal: 100)
        account.save()
        BalanceComputing.recompute(account)
        print("create new account")
        return account
    }
    
    static func deleteAcocunt(account: Account) {
        account.delete()
        print("delete account")
    }
}
