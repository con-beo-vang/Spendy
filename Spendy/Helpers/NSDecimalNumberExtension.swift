//
//  NSDecimalNumberExtension.swift
//  Spendy
//
//  Created by Harley Trung on 10/5/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import Foundation

extension NSDecimalNumber: Comparable {}

public func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

// MARK: - Arithmetic Operators

public prefix func -(value: NSDecimalNumber) -> NSDecimalNumber {
    return value.decimalNumberByMultiplyingBy(NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true))
}

public func +(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberByAdding(rhs)
}

public func -(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberBySubtracting(rhs)
}

public func *(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberByMultiplyingBy(rhs)
}

public func /(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberByDividingBy(rhs)
}

public func ^(lhs: NSDecimalNumber, rhs: Int) -> NSDecimalNumber {
    return lhs.decimalNumberByRaisingToPower(rhs)
}