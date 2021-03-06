//
//  QuickCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class QuickCell: UITableViewCell {
  
  @IBOutlet weak var iconView: UIImageView!
  
  @IBOutlet weak var categoryLabel: UILabel!
  
  // TODO: fix typo
  @IBOutlet weak var amountSegment: UISegmentedControl!
  
  var amountValues: [NSDecimalNumber]! {
    didSet {
      for (index, option) in amountValues.enumerate() {
        amountSegment.setTitle(option.stringValue, forSegmentAtIndex: index)
      }
    }
  }
  
  var transaction: Transaction! {
    didSet {
      let category = transaction.category!
      categoryLabel.text = category.name
      iconView.image = Helper.sharedInstance.createIcon(category.icon!)
      iconView.setNewTintColor(UIColor.whiteColor())
      // it is possible to support a different category color here
      iconView.layer.backgroundColor = Color.expenseColor.CGColor
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let font = UIFont.systemFontOfSize(17)
    let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
    amountSegment.setTitleTextAttributes(attributes as [NSObject : AnyObject], forState: UIControlState.Normal)
    
    Helper.sharedInstance.setIconLayer(iconView)
    
    categoryLabel.textColor = Color.quickCategoryColor
    amountSegment.tintColor = Color.quickSegmentColor
  }
  
}
