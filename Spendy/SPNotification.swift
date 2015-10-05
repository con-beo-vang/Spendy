//
//  SPNotification.swift
//  Spendy
//
//  Created by Harley Trung on 10/5/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation

class SPNotification {
    static let transactionsLoadedForAccount = "TransactionsLoadedForAccount"
    static let transactionAddedOrUpdated    = "TransactionAddedOrUpdated"
    static let accountAddedOrUpdated        = "AccountAddedOrUpdated"
    static let allCategoriesLoaded          = "AllCategoriesLoaded"
    static let allAccountsLoaded            = "AllAccountsLoaded"
    static let recomputedBalanceForOneAccount = "RecomputedBalanceForOneAccount"
    static let groupedStatsOnExpenseCategories = "GroupedStatsOnExpenseCategories"
    static let finishedBootstrapingCategories  = "FinishedBootstrapCategories"
}