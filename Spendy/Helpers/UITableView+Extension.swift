//
//  UITableView+Extension.swift
//  Spendy
//
//  Created by Dave Vo on 11/14/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

extension UITableView {
  func reloadDataWithBlock(completion: ()->()) {
    UIView.animateWithDuration(0, animations: { self.reloadData() })
      { _ in completion() }
  }
}
