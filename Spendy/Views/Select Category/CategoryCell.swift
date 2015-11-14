//
//  CategoryCell.swift
//  Spendy
//
//  Created by Harley Trung on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var selectedIcon: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    Helper.sharedInstance.setIconLayer(iconImageView)
  }
}
