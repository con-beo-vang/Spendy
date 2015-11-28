//
//  TransactionGrouping.swift
//  Spendy
//
//  Created by Harley Trung on 10/18/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation

struct TransactionGrouping {
  static func listGroupedByMonth(trans: [Transaction]) -> [[Transaction]] {
    let grouped = dictGroupedByMonth(trans)
    
    var list: [[Transaction]] = []
    
    for (month, _) in grouped {
      var g:[Transaction] = grouped[month]!
      
      // sort values in each bucket, newest first
      g.sortInPlace({
        guard $1.date != nil && $0.date != nil else { return true }
        return $1.date! < $0.date!
      })
      list.append(g)
    }
    
    // sort by month
    list.sortInPlace({ $1[0].date! < $0[0].date! })
    
    return list
  }
  
  static func dictGroupedByMonth(trans: [Transaction]) -> [String: [Transaction]] {
    var dict = [String: [Transaction]]()
    
    for el in trans {
      let key = el.monthHeader() ?? "Unknown"
      dict[key] = (dict[key] ?? []) + [el]
    }
    return dict
  }
}
