//
//  Helper.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class Helper: NSObject {
   
    class var sharedInstance: Helper {
        struct Static {
            static let instance = Helper()
        }
        
        return Static.instance
    }
    
    func customizeBarButton(viewController: UIViewController, button: UIButton, imageName: String, isLeft: Bool) {
        
        let avatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        avatar.image = UIImage(named: imageName)
        
        button.setImage(avatar.image, forState: .Normal)
        button.frame = CGRectMake(0, 0, 22, 22)
        
        let item: UIBarButtonItem = UIBarButtonItem()
        item.customView = button
        //        item.customView?.layer.cornerRadius = 11
        //        item.customView?.layer.masksToBounds = true
        if isLeft {
            viewController.navigationItem.leftBarButtonItem = item
        } else {
            viewController.navigationItem.rightBarButtonItem = item
        }
    }
    
    func setSeparatorFullWidth(cell: UITableViewCell) {
        // Set full width for the separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    func getCellAtGesture(gestureRecognizer: UIGestureRecognizer, tableView: UITableView) -> UITableViewCell? {
        let location = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(location)
        if let indexPath = indexPath {
            return tableView.cellForRowAtIndexPath(indexPath)!
        } else {
            return nil
        }
    }
    
    func getWeek(weekOfYear: Int) -> (NSDate?, NSDate?) {
        
        var beginningOfWeek: NSDate?
        var endOfWeek: NSDate?
        
        let cal = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.weekOfYear = weekOfYear
        
        if let date = cal.dateByAddingComponents(components, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0)) {
            var weekDuration = NSTimeInterval()
            if cal.rangeOfUnit(NSCalendarUnit.NSWeekOfYearCalendarUnit, startDate: &beginningOfWeek, interval: &weekDuration, forDate: date) {
                endOfWeek = beginningOfWeek?.dateByAddingTimeInterval(weekDuration)
            }
            
            beginningOfWeek = cal.dateByAddingUnit(NSCalendarUnit.NSDayCalendarUnit, value: 1, toDate: beginningOfWeek!, options: NSCalendarOptions(rawValue: 0))
            
        }
        
        return (beginningOfWeek!, endOfWeek!)
    }
}

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

enum ViewMode: Int {
    case Weekly = 0,
    Monthly,
    Yearly,
    Custom
}
