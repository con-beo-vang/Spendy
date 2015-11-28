//
//  KindColor.swift
//  Spendy
//
//  Created by Harley Trung on 10/18/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation
import UIKit

struct KindColor {
  static func forKind(kind: String) -> UIColor {
    switch kind {
    case CategoryType.Expense.rawValue:
      return Color.expenseColor
    case CategoryType.Income.rawValue:
      return Color.incomeColor
    default:
      return Color.balanceColor
    }
  }
  
  static func forTransaction(transaction: Transaction, account: Account) -> UIColor {
    if transaction.isTransfer() {
      if transaction.toAccount == account {
        return Color.incomeColor
      } else {
        return Color.expenseColor
      }
    } else {
      return forKind(transaction.kind!)
    }
  }
}
