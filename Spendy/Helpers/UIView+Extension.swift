//
//  UIView+Extension.swift
//  Spendy
//
//  Created by Chau Vo on 12/19/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

extension UIView {
  func hasTapGesture() -> Bool {
    if let gestures = self.gestureRecognizers {
      for gesture in gestures {
        if gesture is UITapGestureRecognizer {
          return true
        }
      }
    }
    return false
  }
}
