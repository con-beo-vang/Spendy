//
//  DefaultAccountCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/26/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class DefaultAccountCell: UITableViewCell {
    
    @IBOutlet weak var defaultAccountLabel: UILabel!

    var account: RAccount! {
        didSet {
            defaultAccountLabel.text = account.name
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
