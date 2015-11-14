//
//  DateUtilities.swift
//  Spendy
//
//  Created by Harley Trung on 9/21/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import Foundation

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

extension NSDate: Comparable { }

class DateFormatter {
    static func formatFromString(format: String? = nil, style: NSDateFormatterStyle? = nil) -> NSDateFormatter {
        let formatter = NSDateFormatter()
        if let format = format {
            formatter.dateFormat = format
        }
        if let style = style {
            formatter.dateStyle = style
        }
        return formatter
    }
    static var E_MMM_dd_yyyy   = DateFormatter.formatFromString("E, MMM dd, yyyy")
    static var EEE_MMM_dd_yyyy = DateFormatter.formatFromString("EEE, MMM dd, yyyy")
    static var fullStyle       = DateFormatter.formatFromString(style: NSDateFormatterStyle.FullStyle)
    static var MM_dd_yyyy_hh_mm_ss = DateFormatter.formatFromString("MM-dd-yyyy hh:mm:ss")

    static var MMMM_dd_yyyy    = DateFormatter.formatFromString("MMMM dd, yyyy")
    static var MMM_dd_yyyy     = DateFormatter.formatFromString("MMM dd, yyyy")
    static var MM_dd_yyyy      = DateFormatter.formatFromString("MM-dd-yyyy")
    static var dd_MMMM         = DateFormatter.formatFromString("dd MMMM")
    static var YYYY_MM_dd      = DateFormatter.formatFromString("YYYY-MM-dd")

    static var MMMM            = DateFormatter.formatFromString("MMMM")
    static var yyyy            = DateFormatter.formatFromString("yyyy")

    static var hh_mm_a         = DateFormatter.formatFromString("hh:mm a")
    static var h_mm_a          = DateFormatter.formatFromString("h:mm a")
}