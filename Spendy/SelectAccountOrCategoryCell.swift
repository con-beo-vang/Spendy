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
            itemTypeFilter = category.type()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}