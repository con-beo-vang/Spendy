//
//  String+Extension.swift
//  Spendy
//
//  Created by Dave Vo on 11/14/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation

extension String {
  subscript (r: Range<Int>) -> String {
    get {
      let startIndex = self.startIndex.advancedBy(r.startIndex)
      let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
      return self[Range(start: startIndex, end: endIndex)]
    }
  }
  
  func replace(target: String, withString: String) -> String {
    return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
  }
}
