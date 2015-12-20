//
//  UIViewController+Extension.swift
//  Spendy
//
//  Created by Chau Vo on 12/20/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

extension UIViewController {
  func showAlert(title title: String, message: String?, actionTitle: String) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    ac.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
    presentViewController(ac, animated: true, completion: nil)
  }
}
