//
//  AddReminderCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/27/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class AddReminderCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconView.setNewTintColor(Color.strongColor)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
