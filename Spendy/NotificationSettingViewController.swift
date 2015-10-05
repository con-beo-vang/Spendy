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
    
    var userCategories = [UserCategory]()
    
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
        
        // get list user categories with time slots
        userCategories = UserCategory.allWithReminderSettings()
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
    
    func reminderCellSwitchValueChanged(reminderCell: ReminderCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(reminderCell)!

        let userCategory = userCategories[indexPath.row]

        if value {
            // Add all active time slots of this category
            userCategory.turnOn()
            print("Turn on reminders for \(userCategory.name)")
        } else {
            // Remove all active time slots of this category
            userCategory.turnOff()
            print("Remove all reminders for \(userCategory.name)")
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
            if indexPath.row < userCategories.count {
                addViewController.selectedUserCategory = userCategories[indexPath.row]
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
        return userCategories.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row != userCategories.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderCell
            
            cell.userCategory = userCategories[indexPath.row]
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
                guard let indexPath = tableView.indexPathForCell(reminderCell) else { break }

                let userCat = userCategories[indexPath.row]
                userCat.removeSelfAndAllReminders()
                userCategories.removeAtIndex(indexPath.row)

                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            break
            
        default:
            break
        }
    }
}
