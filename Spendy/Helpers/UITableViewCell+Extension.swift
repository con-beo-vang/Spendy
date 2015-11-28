//
//  UITableViewCell+Extension.swift
//  Spendy
//
//  Created by Dave Vo on 11/14/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

extension UITableViewCell {
  func setSeparatorFullWidth() {
    layoutMargins = UIEdgeInsetsZero
    preservesSuperviewLayoutMargins = false
    separatorInset = UIEdgeInsetsZero
  }
}
