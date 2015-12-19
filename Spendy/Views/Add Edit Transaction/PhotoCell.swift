//
//  PhotoCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/17/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
  @IBOutlet weak var photoView: UIImageView!
  
  @IBOutlet weak var cameraIcon: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    photoView.layer.cornerRadius = 5
    photoView.layer.masksToBounds = true
  }
}
