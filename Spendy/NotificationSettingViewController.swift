//l
//  NotificationSettingViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/19/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class NotificationSettingViewController: UIViewController, ReminderCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var addButton: UIButton!
    var backButton: UIButton!
    
    var reminders = [UserCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62
        
        addBarButton()
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        downSwipe.direction = .Down
        downSwipe.delegate = self
        tableView.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        leftSwipe.direction = .Left
        leftSwipe.delegate = self
        tableView.addGestureRecognizer(leftSwipe)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Load data from Parse when this view will appear
        // (both cases from Settings view and from Add reminder view
        // The right way is creating a delegate for AddReminderViewController
        // and passing data through the delegate
        // But it's so complicated to handle in this view
        // so I use the "cheating" way :D
        // If you don't like this, you can use delegate. It's up to you.
        
        // TODO: Load data from Parse
        // Each cell is a Category which has the number of ReminderItem > 0
        
        // get list categories with time slots
        // TODO: time slot must be for the current user
        // Reminder(user: user, category: cateogry)
        reminders = UserCategory.allWithReminderSettings()
        tableView.reloadData()
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
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Implement delegate
    
    func reminderCell(reminderCell: ReminderCell, didChangeValue value: Bool) {
        
        let indexPath = tableView.indexPathForCell(reminderCell)!
        print("switch cell")
        if value {
            // Add all active time slots of this category
            for item in reminders[indexPath.row].timeSlots {
                if item.isActive {
                    ReminderList.sharedInstance.addReminderNotification(item)
                }
            }
            print("active reminder")
        } else {
            // Remove all active time slots of this category
            for item in reminders[indexPath.row].timeSlots {
                if item.isActive {
                    ReminderList.sharedInstance.removeReminderNotification(item)
                }
            }
            print("remove reminder")
        }
    }
    
    // MARK: Transfer between 2 views
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        
        if vc is AddReminderViewController {
            let addViewController = vc as! AddReminderViewController
            
            var indexPath: AnyObject!
            indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            
            // If select 1 remider
            if indexPath.row < reminders.count {
                addViewController.selectedUserCategory = reminders[indexPath.row]
            }
        }
    }
    
}

// MARK: Table view

extension NotificationSettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 62
    //    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row != reminders.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderCell
            
            cell.category = reminders[indexPath.row].category
            cell.delegate = self
            
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddReminderCell", forIndexPath: indexPath) as! AddReminderCell
            cell.titleLabel.text = "Add category to remind"
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
        }
    }
}

// MARK: Handle gesture

extension NotificationSettingViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
            
        case UISwipeGestureRecognizerDirection.Down:
            performSegueWithIdentifier("AddNewReminder", sender: self)
            break
            
        case UISwipeGestureRecognizerDirection.Left:
            let selectedCell = Helper.sharedInstance.getCellAtGesture(sender, tableView: tableView)
            
            if selectedCell is ReminderCell {
                let reminderCell = selectedCell as! ReminderCell
                let indexPath = tableView.indexPathForCell(reminderCell)
                
                for item in reminders[indexPath!.row].timeSlots {
                    // Remove all active time slots of this category from Notification
                    if item.isActive {
                        ReminderList.sharedInstance.removeReminderNotification(item)
                    }
                    // TODO: Delete reminder item
                }
                
                if let indexPath = indexPath {
                    reminders.removeAtIndex(indexPath.row)
                    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
            break
            
        default:
            break
        }
    }
}
