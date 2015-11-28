//
//  UITextField+Extension.swift
//  Spendy
//
//  Created by Dave Vo on 11/14/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

extension UITextField {
  func preventInputManyDots() {
    if text?.characters.last == "." {
      if var sAmount : String = text {
        sAmount = sAmount[0..<sAmount.characters.count - 1]
        
        if sAmount.rangeOfString(".") != nil {
          text = sAmount
        }
      }
    }
  }
}
