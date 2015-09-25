//
//  AccountCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/17/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!


    var account: Account! {
        didSet {
            balanceLabel.text = account.formattedBalance()
            nameLabel.text = account.name
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
