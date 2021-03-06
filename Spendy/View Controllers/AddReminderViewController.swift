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
  
  var selectedUserCategory: UserCategory!
  var isNewReminder = false
  
  // MARK: - Main functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    
    if !isNewReminder {
      navigationItem.title = "Edit Reminder"
    }
    
    addBarButton()
    addGestures()
  }
  
  // MARK: Button
  
  func addBarButton() {
    backButton = UIButton()
    Helper.sharedInstance.customizeBarButton(self, button: backButton!, imageName: "Bar-Back", isLeft: true)
    backButton!.addTarget(self, action: "onBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
  }
  
  func onBackButton(sender: UIButton!) {
    if isNewReminder {
      // Pop 2 view controller, back to Notification Settings view
      let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
      self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    } else {
      navigationController?.popViewControllerAnimated(true)
    }
  }
  
  // MARK: Implement delegate
  
  func timeCellSwitchValueChanged(timeCell: TimeCell, didChangeValue value: Bool) {
    let indexPath = tableView.indexPathForCell(timeCell)!
    print("switch control \(value)")
    
    timeCell.onSwitch.on = value
    
    let reminderItem = selectedUserCategory.timeSlots[indexPath.row]
    selectedUserCategory.updateReminder(reminderItem, newValue: value)
  }
  
}

// MARK: - Table view

extension AddReminderViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectedUserCategory.timeSlots.count + 1
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 40))
    headerView.backgroundColor = UIColor(netHex: 0xDCDCDC)
    
    let categoryNameLabel = UILabel(frame: CGRect(x: 0, y: 10, width: UIScreen.mainScreen().bounds.width, height: 20))
    categoryNameLabel.text = selectedUserCategory.name
    categoryNameLabel.textAlignment = .Center
    headerView.addSubview(categoryNameLabel)
    
    return headerView
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row < selectedUserCategory.timeSlots.count {
      let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath) as! TimeCell
      
      cell.reminderItem = selectedUserCategory.timeSlots[indexPath.row]
      cell.delegate = self
      
      cell.setSeparatorFullWidth()
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("AddTimeCell", forIndexPath: indexPath) as! AddReminderCell
      cell.titleLabel.text = "Add time"
      cell.setSeparatorFullWidth()
      return cell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row < selectedUserCategory.timeSlots.count {
      
      let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? TimeCell
      let timeString = selectedCell!.timeLabel.text
      
      let defaultDate = DateFormatter.hh_mm_a.dateFromString(timeString!)
      
      DatePickerDialog().show(title: "Choose Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: defaultDate!, minDate: nil, datePickerMode: .Time) {
        (time) -> Void in
        
        // update reminder item
        print("Newly picked time: \(time)")
        
        self.selectedUserCategory.updateReminder(indexPath.row, newTime: time)
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
      }
    } else {
      addTime()
    }
  }
  
}

// MARK: - Handle gestures

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
        ReminderList.sharedInstance.removeReminderNotification(selectedUserCategory.timeSlots[indexPath!.row])
        print("remove old notification")
        
        if let indexPath = indexPath {
          let item = selectedUserCategory.timeSlots[indexPath.row]
          selectedUserCategory.removeReminder(item)
          
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
      print("addTime: \(time)")
      
      // Add notification
      self.selectedUserCategory.addReminder(time)
      
      self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
  }
  
}
