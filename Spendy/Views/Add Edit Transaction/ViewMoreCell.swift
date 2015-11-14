//
//  ViewMoreCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/27/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class ViewMoreCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    titleLabel.textColor = Color.moreDetailColor
  }
}
