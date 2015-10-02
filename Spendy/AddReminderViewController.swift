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
    
    var selectedCategory: Category!
    var isNewReminder = false
    
    var formatter: NSDateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBarButton()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        if !isNewReminder {
            navigationItem.title = "Edit Reminder"
        }
        
        addGestures()
        
        formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button
    
    func addBarButton() {
        
        backButton = UIButton()
        Helper.sharedInstance.customizeBarButton(self, button: backButton!, imageName: "Bar-Back", isLeft: true)
        backButton!.addTarget(self, action: "onBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onBackButton(sender: UIButton!) {
        print("on Back", terminator: "\n")
        if isNewReminder {
            // Pop 2 view controller, back to Notification Settings view
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Implement delegate
    
    func timeCell(timeCell: TimeCell, didChangeValue value: Bool) {
        
        let indexPath = tableView.indexPathForCell(timeCell)!
        print("switch time", terminator: "\n")
        
        selectedCategory.timeSlots[indexPath.row].isActive = value
        // TODO: update in Parse
        timeCell.onSwitch.on = value
        if value {
            ReminderList.sharedInstance.addReminderNotification(selectedCategory.timeSlots[indexPath.row])
            print("add new notification")
        } else {
            // pass ReminderItem of this cell to this method
            ReminderList.sharedInstance.removeReminderNotification(selectedCategory.timeSlots[indexPath.row])
            print("remove old notification")
        }
    }
}

// MARK: Table view

extension AddReminderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCategory.timeSlots.count + 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 40))
        headerView.backgroundColor = UIColor(netHex: 0xDCDCDC)
        
        let categoryNameLabel = UILabel(frame: CGRect(x: 0, y: 10, width: UIScreen.mainScreen().bounds.width, height: 20))
        categoryNameLabel.text = selectedCategory.name
        categoryNameLabel.textAlignment = .Center
        headerView.addSubview(categoryNameLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row < selectedCategory.timeSlots.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath) as! TimeCell
            
            cell.reminderItem = selectedCategory.timeSlots[indexPath.row]
            cell.delegate = self
            
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddTimeCell", forIndexPath: indexPath) as! AddReminderCell
            cell.titleLabel.text = "Add time"
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < selectedCategory.timeSlots.count {
            
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? TimeCell
            let timeString = selectedCell!.timeLabel.text
            
            let defaultDate = formatter.dateFromString(timeString!)
            
            DatePickerDialog().show(title: "Choose Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: defaultDate!, minDate: nil, datePickerMode: .Time) {
                (time) -> Void in
                print(time, terminator: "\n")
                
                var selectedItem = self.selectedCategory.timeSlots[indexPath.row]
                
                // Remove old notification
                ReminderList.sharedInstance.removeReminderNotification(selectedItem)
                print("remove old notification")
                
                // Turn on switch automatically
                selectedItem.isActive = true
                
                // Add new notification
                selectedItem.reminderTime = time
                ReminderList.sharedInstance.addReminderNotification(selectedItem)
                
                self.selectedCategory.timeSlots[indexPath.row] = selectedItem
                print("add new notification")
                // TODO: update this item in Parse
                
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        } else {
            addTime()
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
                
                // Remove old notification
                ReminderList.sharedInstance.removeReminderNotification(selectedCategory.timeSlots[indexPath!.row])
                print("remove old notification")
                
                if let indexPath = indexPath {
                    selectedCategory.timeSlots.removeAtIndex(indexPath.row)
                    // TODO: remove this item in Parse
                    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
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
            let newItem = ReminderItem(category: self.selectedCategory, reminderTime: time, UUID: NSUUID().UUIDString)
            ReminderList.sharedInstance.addReminderNotification(newItem)
            self.selectedCategory.timeSlots.append(newItem)
            // TODO: add newItem to Parse
            
            print("add new notification")
            
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tapSelectCategory(sender: UITapGestureRecognizer) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectCategoryVC = storyboard.instantiateViewControllerWithIdentifier("SelectAccountOrCategoryVC") as! SelectAccountOrCategoryViewController
        
        selectCategoryVC.itemClass = "Category"
        
        navigationController?.pushViewController(selectCategoryVC, animated: true)
        
    }
}