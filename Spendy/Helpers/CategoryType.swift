//
//  CategoryType.swift
//  Spendy
//
//  Created by Harley Trung on 10/18/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

enum CategoryType: String {
  case Income = "Income", Expense = "Expense", Transfer = "Transfer"
  
  static let allValues = [Income, Expense, Transfer]
  static let allValueStrings = [Income.rawValue, Expense.rawValue, Transfer.rawValue]
}
