//
//  UIImageView+Extension.swift
//  Spendy
//
//  Created by Dave Vo on 11/14/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

extension UIImageView {
  func setNewTintColor(color: UIColor) {
    self.image = self.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    self.tintColor = color
  }
}
