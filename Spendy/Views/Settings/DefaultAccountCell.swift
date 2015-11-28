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
  
  var account: Account! {
    didSet {
      defaultAccountLabel.text = account.name
    }
  }
}
