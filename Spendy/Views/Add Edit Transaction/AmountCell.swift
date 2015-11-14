//
//  AmountCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class AmountCell: UITableViewCell {
  @IBOutlet weak var typeSegment: UISegmentedControl!
  @IBOutlet weak var amountText: UITextField!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    typeSegment.selectedSegmentIndex = 1
    typeSegment.tintColor = Color.expenseColor
  }
}
