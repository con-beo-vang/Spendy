//
//  AddReminderViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/19/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController, TimeCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var addButton: UIButton!
    var backButton: UIButton!
    
    var selectedRemider: String!
    
    var times = [String]()
    
    var formatter: NSDateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBarButton()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        if selectedRemider != nil {
            navigationItem.title = "Edit Reminder"
        }
        
        addGestures()
        
        formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        // TODO: Change to TimeSlot object. Each category has a list of time slot
        // TimeSlot { 
        //        reminderItem: ReminderItem
        //        isActive: Bool
        // }
        
        
        times = ["08:00 AM", "02:00 PM", "07:00 PM"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button
    
    func addBarButton() {
        
        //        addButton = UIButton()
        //        Helper.sharedInstance.customizeBarButton(self, button: addButton!, imageName: "Bar-Tick", isLeft: false)
        //        addButton!.addTarget(self, action: "onAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        backButton = UIButton()
        Helper.sharedInstance.customizeBarButton(self, button: backButton!, imageName: "Bar-Back", isLeft: true)
        backButton!.addTarget(self, action: "onBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    //    func onAddButton(sender: UIButton!) {
    //        print("on Add", terminator: "\n")
    //    }
    
    func onBackButton(sender: UIButton!) {
        print("on Back", terminator: "\n")
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Implement delegate
    
    func timeCell(timeCell: TimeCell, didChangeValue value: Bool) {
        
        //        let indexPath = tableView.indexPathForCell(timeCell)!
        print("switch time", terminator: "\n")
        
        // TODO: handle time switch
        if value {
            // pass params category and predictive amount to this method
            //            ReminderList.sharedInstance.addReminderNotification("Meal", amount: 5.00, date: formatter.dateFromString(timeCell.timeLabel.text!)!)
            print("add new notification")
        } else {
            // pass ReminderItem of this cell to this method
            //            ReminderList.sharedInstance.removeReminderNotification(<#T##item: ReminderItem##ReminderItem#>)
            print("remove old notification")
        }
    }
    
}

// MARK: Table view

extension AddReminderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return times.count + 1
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 30))
        headerView.backgroundColor = UIColor(netHex: 0xDCDCDC)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryReminderCell", forIndexPath: indexPath) as! CategoryReminderCell
            
            if let selectedRemider = selectedRemider {
                cell.categoryLabel.text = selectedRemider
            }
            
            let tapSelectCategory = UITapGestureRecognizer(target: self, action: Selector("tapSelectCategory:"))
            tapSelectCategory.delegate = self
            cell.addGestureRecognizer(tapSelectCategory)
            
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
            
        } else {
            
            if indexPath.row < times.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath) as! TimeCell
                
                cell.delegate = self
                cell.timeLabel.text = times[indexPath.row]
                
                Helper.sharedInstance.setSeparatorFullWidth(cell)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddTimeCell", forIndexPath: indexPath) as! AddReminderCell
                cell.titleLabel.text = "Add time"
                Helper.sharedInstance.setSeparatorFullWidth(cell)
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if indexPath.row < times.count {
                
                let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? TimeCell
                let timeString = selectedCell!.timeLabel.text
                
                let defaultDate = formatter.dateFromString(timeString!)
                
                DatePickerDialog().show(title: "Choose Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: defaultDate!, minDate: nil, datePickerMode: .Time) {
                    (time) -> Void in
                    print(time, terminator: "\n")
                    
                    // TODO: Handle edit time. Pass params to these method
                    // Remove old notification
                    //                    ReminderList.sharedInstance.removeReminderNotification(<#T##item: ReminderItem##ReminderItem#>)
                    print("remove old notification")
                    
                    // Turn on switch automatically <--- needed?
                    selectedCell?.onSwitch.on = true
                    
                    // Add new notification
                    //                    ReminderList.sharedInstance.addReminderNotification("Meal", amount: 5.00, date: time)
                    print("add new notification")
                    
                    let timeString = self.formatter.stringFromDate(time)
                    print("formated: \(timeString)", terminator: "\n")
                    self.times[indexPath.row] = timeString
                    
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            } else {
                addTime()
            }
        }
    }
    
}

// MARK: Handle gestures

extension AddReminderViewController: UIGestureRecognizerDelegate {
    
    func addGestures() {
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        downSwipe.direction = .Down
        downSwipe.delegate = self
        tableView.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        leftSwipe.direction = .Left
        leftSwipe.delegate = self
        tableView.addGestureRecognizer(leftSwipe)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Down:
            addTime()
            break
            
        case UISwipeGestureRecognizerDirection.Left:
            let selectedCell = Helper.sharedInstance.getCellAtGesture(sender, tableView: tableView)
            
            if selectedCell is TimeCell {
                let timeCell = selectedCell as! TimeCell
                let indexPath = tableView.indexPathForCell(timeCell)
                
                // TODO: Handle remove notification. Pass params to these method
                // Remove old notification
                //                    ReminderList.sharedInstance.removeReminderNotification(<#T##item: ReminderItem##ReminderItem#>)
                print("remove old notification")
                
                if let indexPath = indexPath {
                    times.removeAtIndex(indexPath.row)
                    tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
            break
            
        default:
            break
        }
    }
    
    func addTime() {
        
        DatePickerDialog().show(title: "Choose Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minDate: nil, datePickerMode: .Time) {
            (time) -> Void in
            print(time, terminator: "\n")
            
            // Add notification
            // TODO: pass params category and predictive amount to this method
            //            ReminderList.sharedInstance.addReminderNotification("Meal", amount: 5.00, date: time)
            print("add new notification")
            
            let timeString = self.formatter.stringFromDate(time)
            print("formated: \(timeString)", terminator: "\n")
            self.times.append(timeString)
            
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tapSelectCategory(sender: UITapGestureRecognizer) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectCategoryVC = storyboard.instantiateViewControllerWithIdentifier("SelectAccountOrCategoryVC") as! SelectAccountOrCategoryViewController
        
        selectCategoryVC.itemClass = "Category"
        
        navigationController?.pushViewController(selectCategoryVC, animated: true)
        
    }
}
