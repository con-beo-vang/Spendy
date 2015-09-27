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
        // Initialization code
        typeSegment.selectedSegmentIndex = 1
        typeSegment.tintColor = Color.expenseColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
