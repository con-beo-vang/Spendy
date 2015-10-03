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
    @IBOutlet weak var amoutSegment: UISegmentedControl!

    var amountValues: [NSDecimalNumber]! {
        didSet {
            for (index, option) in amountValues.enumerate() {
                amoutSegment.setTitle(option.stringValue, forSegmentAtIndex: index)
            }
        }
    }

    var transaction: Transaction! {
        didSet {
            let category = transaction.category!
            categoryLabel.text = category.name
            iconView.image = Helper.sharedInstance.createIcon(category.icon)
            iconView.setNewTintColor(UIColor.whiteColor())
            // it is possible to support a different category color here
            iconView.layer.backgroundColor = Color.expenseIconColor.CGColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let font = UIFont.systemFontOfSize(17)
        let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
        amoutSegment.setTitleTextAttributes(attributes as [NSObject : AnyObject], forState: UIControlState.Normal)
        
        Helper.sharedInstance.setIconLayer(iconView)
        
        categoryLabel.textColor = Color.quickCategoryColor
        amoutSegment.tintColor = Color.quickSegmentColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
