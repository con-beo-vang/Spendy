//
//  DecimalConverter.swift
//  Spendy
//
//  Created by Harley Trung on 10/18/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation

struct DecimalConverter {
    static func intToDecimal(val: Int) -> NSDecimalNumber {
        return NSDecimalNumber(integer: val) * 0.01
    }

    static func decimalToInt(newValue: NSDecimalNumber?) -> Int {
        guard let val = newValue where val != NSDecimalNumber.notANumber() else {
            return 0
        }
        return (val * 100).integerValue
    }
}