//
//  SelectAccountOrCategoryCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class SelectAccountOrCategoryCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!
  
  var itemClass: String!
  var itemTypeFilter: String?
  
  var category: Category? {
    didSet {
      guard let category = category else { return }
      titleLabel.text = "Category"
      typeLabel.text = category.name
      
      itemTypeFilter = category.type
      print("[SelectAccountOrCategoryCell] itemTypeFilter = \(itemTypeFilter)")
    }
  }
  
  var account: Account? {
    didSet {
      titleLabel.text = "Account"
      typeLabel.text = account?.name ?? "None"
      itemTypeFilter = "Account"
    }
  }
  
  var fromAccount: Account? {
    didSet {
      titleLabel.text = "From Account"
      typeLabel.text = fromAccount?.name ?? "None"
      itemTypeFilter = "FromAccount"
    }
  }
  
  var toAccount: Account? {
    didSet {
      guard let account = toAccount else {
        titleLabel.text = "To Account"
        typeLabel.text = "None"
        return
      }
      titleLabel.text = "To Account"
      typeLabel.text = account.name
      itemTypeFilter = "ToAccount"
    }
  }
}
