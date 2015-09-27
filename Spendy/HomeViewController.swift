//
//  HomeViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import QuartzCore

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var statusBarView: UIView!
    
    @IBOutlet weak var currentBarView: UIView!
    
    @IBOutlet weak var currentBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var todayLabel: UILabel!
    
    
    @IBOutlet weak var popupSuperView: UIView!
    
    // View Mode
    
    @IBOutlet weak var viewModePopup: UIView!
    
    @IBOutlet weak var viewModeTitleLabel: UILabel!
    
    @IBOutlet weak var viewModeTableView: UITableView!
    
    // Select Date
    
    @IBOutlet weak var datePopup: UIView!
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    
    @IBOutlet weak var fromButton: UIButton!
    
    @IBOutlet weak var toButton: UIButton!
    
    var formatter: NSDateFormatter!
    
    let dayCountInMonth = 30
    
    var incomes = [String]()
    var expenses = [String]()
    
    var isCollapedIncome = true
    var isCollapedExpense = true
    
    var viewMode = ViewMode.Monthly
    var weekOfYear = 0
    
    let customPresentAnimationController = CustomPresentAnimationController()
    let customDismissAnimationController = CustomDismissAnimationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Home")
        
        settingStatusBar()
        
        navigationItem.title = getTodayString("MMMM")
        let tapTitle = UITapGestureRecognizer(target: self, action: Selector("chooseMode:"))
        navigationController?.navigationBar.addGestureRecognizer(tapTitle)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        leftSwipe.direction = .Left
        leftSwipe.delegate = self
        tableView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        rightSwipe.direction = .Right
        rightSwipe.delegate = self
        tableView.addGestureRecognizer(rightSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        downSwipe.direction = .Down
        downSwipe.delegate = self
        tableView.addGestureRecognizer(downSwipe)
        
        viewModeTableView.dataSource = self
        viewModeTableView.delegate = self
        viewModeTableView.tableFooterView = UIView()
        
        
        incomes = ["Salary", "Bonus"]
        expenses = ["Meal", "Drink", "Transport"]
        
        
        configPopup()

        
        
        
//        for item in (tabBarController?.tabBar.items)! {
//            if let image = item.image {
//                item.image = image.imageWithRenderingMode(.AlwaysOriginal)
//            }
//        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: View mode
    
    func settingStatusBar() {
        currentBarView.layer.cornerRadius = 6
        currentBarView.layer.masksToBounds = true
        
        statusBarView.layer.cornerRadius = 6
        statusBarView.layer.masksToBounds = true
        
        todayLabel.text = getTodayString("MMMM dd, yyyy")
        
        let day = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: NSDate())
        var ratio = CGFloat(day) / CGFloat(dayCountInMonth)
        ratio = ratio > 1 ? 1 : ratio
        currentBarWidthConstraint.constant = ratio * statusBarView.frame.width
    }
    
    func chooseMode(sender: UITapGestureRecognizer) {
        print("tap title", terminator: "\n")
        showPopup(viewModePopup)
    }
    
    func getWeekText(weekOfYear: Int) -> String {
        var result = "Weekly"
        let (beginWeek, endWeek) = Helper.sharedInstance.getWeek(weekOfYear)
        if beginWeek != nil && endWeek != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd MMM"
            result = formatter.stringFromDate(beginWeek!) + " - " + formatter.stringFromDate(endWeek!)
        }
        return result
    }
    
    func getTodayString(dateFormat: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(NSDate())
    }
    
    func configPopup() {
        
        formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        popupSuperView.hidden = true
        popupSuperView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        Helper.sharedInstance.setPopupShadowAndColor(viewModePopup, label: viewModeTitleLabel)
        Helper.sharedInstance.setPopupShadowAndColor(datePopup, label: dateTitleLabel)
        
        let today = NSDate()
        fromButton.setTitle(formatter.stringFromDate(today), forState: UIControlState.Normal)
        toButton.setTitle(formatter.stringFromDate(today), forState: UIControlState.Normal)
    }
    
    
    
    // MARK: Button
    
    @IBAction func onFromButton(sender: UIButton) {
        
        let defaultDate = formatter.dateFromString((sender.titleLabel?.text)!)
        
        DatePickerDialog().show(title: "From Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: defaultDate!, minDate: nil, datePickerMode: .Date) {
            (date) -> Void in
            print(date, terminator: "\n")
            
            let dateString = self.formatter.stringFromDate(date)
            print("formated: \(dateString)", terminator: "\n")
            sender.setTitle(dateString, forState: UIControlState.Normal)
            
            let currentToDate = self.formatter.dateFromString((self.toButton.titleLabel?.text)!)
            if currentToDate < date {
                self.toButton.setTitle(self.formatter.stringFromDate(date), forState: UIControlState.Normal)
            }
        }
        
    }
    
    @IBAction func onToButton(sender: UIButton) {
        
        let defaultDate = formatter.dateFromString((sender.titleLabel?.text)!)
        let minDate = formatter.dateFromString((fromButton.titleLabel?.text)!)
        
        DatePickerDialog().show(title: "To Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: defaultDate!, minDate: minDate, datePickerMode: .Date) {
            (date) -> Void in
            print(date, terminator: "\n")
            
            let dateString = self.formatter.stringFromDate(date)
            print("formated: \(dateString)", terminator: "\n")
            sender.setTitle(dateString, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func onDoneDatePopup(sender: UIButton) {
        
        let fromDate = formatter.dateFromString((fromButton.titleLabel!.text)!)
        let toDate = formatter.dateFromString((toButton.titleLabel!.text)!)
        
        let formater2 = NSDateFormatter()
        formater2.dateFormat = "MMM dd, yyyy"
        
        navigationItem.title = formater2.stringFromDate(fromDate!) + " - " + formater2.stringFromDate(toDate!)
        closePopup(datePopup)
    }
    
    @IBAction func onCancelDatePopup(sender: UIButton) {
        closePopup(datePopup)
    }
    
    func showPopup(popupView: UIView) {
        
        popupSuperView.hidden = false
        if popupView == viewModePopup {
            viewModePopup.hidden = false
            datePopup.hidden = true
        } else {
            viewModePopup.hidden = true
            datePopup.hidden = false
        }
        popupView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        popupView.alpha = 0.0;
        popupView.bringSubviewToFront(popupSuperView)
        UIView.animateWithDuration(0.25, animations: {
            popupView.alpha = 1.0
            popupView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func closePopup(popupView: UIView) {
        
        UIView.animateWithDuration(0.25, animations: {
            popupView.transform = CGAffineTransformMakeScale(1.3, 1.3)
            popupView.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished) {
                    self.popupSuperView.hidden = true
                }
        });
    }

}

// MARK: Table view

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.viewModeTableView {
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == viewModeTableView {
            return 4
        } else {
            switch section {
            case 0:
                return isCollapedIncome ? 1 : incomes.count + 1
            case 1:
                return isCollapedExpense ? 1 : expenses.count + 1
            case 2:
                return 1
            default:
                break
            }
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == viewModeTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("ViewModeCell", forIndexPath: indexPath) as! ViewModeCell
            
            switch indexPath.row {
            case 0:
                cell.modeLabel.text = "Weekly"
                break
            case 1:
                cell.modeLabel.text = "Monthly"
                break
            case 2:
                cell.modeLabel.text = "Yearly"
                break
            case 3:
                cell.modeLabel.text = "Custom"
                break
            default:
                break
            }
            
            if indexPath.row == viewMode.rawValue {
                cell.iconView.image = UIImage(named: "CheckCircle")
            } else {
                cell.iconView.image = UIImage(named: "Circle")
            }
            
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
            
        } else {
            
            let dummyCell = UITableViewCell()
            
            switch indexPath.section {
            case 0:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
                    
                    cell.menuLabel.textColor = UIColor(netHex: 0x3D8B37)
                    cell.amountLabel.textColor = UIColor(netHex: 0x3D8B37)
                    cell.menuLabel.text = "Income"
                    
                    if isCollapedIncome {
                        cell.iconView.image = UIImage(named: "Expand")
                    } else {
                        cell.iconView.image = UIImage(named: "Collapse")
                    }
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapIncome:"))
                    cell.addGestureRecognizer(tapGesture)
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("SubMenuCell", forIndexPath: indexPath) as! SubMenuCell
                    
                    cell.categoryLabel.text = incomes[indexPath.row - 1]
                    
                    return cell
                }
                
            case 1:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
                    
                    cell.menuLabel.textColor = UIColor(netHex: 0xCA2437)
                    cell.amountLabel.textColor = UIColor(netHex: 0xCA2437)
                    cell.menuLabel.text = "Expense"
                    
                    if isCollapedExpense {
                        cell.iconView.image = UIImage(named: "Expand")
                    } else {
                        cell.iconView.image = UIImage(named: "Collapse")
                    }
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapExpense:"))
                    cell.addGestureRecognizer(tapGesture)
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("SubMenuCell", forIndexPath: indexPath) as! SubMenuCell
                    
                    cell.categoryLabel.text = expenses[indexPath.row - 1]
                    
                    return cell
                }
                
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("BalanceCell", forIndexPath: indexPath) as! BalanceCell
                
                return cell
                
            default:
                break
            }
            
            return dummyCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == viewModeTableView {
            switch indexPath.row {
            case 0:
                viewMode = ViewMode.Weekly
                navigationItem.title = getWeekText(weekOfYear)
                break
            case 1:
                viewMode = ViewMode.Monthly
                navigationItem.title = getTodayString("MMMM")
                break
            case 2:
                viewMode = ViewMode.Yearly
                navigationItem.title = getTodayString("yyyy")
                break
            case 3:
                viewMode = ViewMode.Custom
                showPopup(datePopup)
                return
            default:
                return
            }
            viewModeTableView.reloadData()
            closePopup(viewModePopup)
        }
    }
}

// MARK: Handle gesture

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        //        var today = NSDate()
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Left:
            switch viewMode {
            case ViewMode.Weekly:
                weekOfYear += 1
                navigationItem.title = getWeekText(weekOfYear)
                
                break
            case ViewMode.Monthly:
                
                break
            case ViewMode.Yearly:
                
                break
            default:
                break
            }
            tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 3)), withRowAnimation: UITableViewRowAnimation.Left)
            break
        case UISwipeGestureRecognizerDirection.Right:
            switch viewMode {
            case ViewMode.Weekly:
                weekOfYear -= 1
                navigationItem.title = getWeekText(weekOfYear)
                
                break
            case ViewMode.Monthly:
                
                break
            case ViewMode.Yearly:
                
                break
            default:
                break
            }
            tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 3)), withRowAnimation: UITableViewRowAnimation.Right)
            break
        case UISwipeGestureRecognizerDirection.Down:
//            let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("QuickVC") as! QuickViewController
//            let nc = UINavigationController(rootViewController: dvc)
//            self.presentViewController(nc, animated: true, completion: nil)
            performSegueWithIdentifier("QuickMode", sender: self)
            break
        default:
            break
        }
    }
    

    
    func tapIncome(sender: UITapGestureRecognizer) {
        if isCollapedIncome {
            isCollapedIncome = false
        } else {
            isCollapedIncome = true
        }
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func tapExpense(sender: UITapGestureRecognizer) {
        if isCollapedExpense {
            isCollapedExpense = false
        } else {
            isCollapedExpense = true
        }
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func tapMode(sender: UITapGestureRecognizer) {
        let selectedCell = Helper.sharedInstance.getCellAtGesture(sender, tableView: viewModeTableView)
        if let selectedCell = selectedCell {
            let indexPath = viewModeTableView.indexPathForCell(selectedCell)
            
            switch indexPath!.row {
            case 0:
                viewMode = ViewMode.Weekly
                navigationItem.title = getWeekText(weekOfYear)
                break
            case 1:
                viewMode = ViewMode.Monthly
                navigationItem.title = getTodayString("MMMM")
                break
            case 2:
                viewMode = ViewMode.Yearly
                navigationItem.title = getTodayString("yyyy")
                break
            case 3:
                viewMode = ViewMode.Custom
                break
            default:
                return
            }
            viewModeTableView.reloadData()
            closePopup(viewModePopup)
        }
    }
}

// MARK: Custom transition

extension HomeViewController: UIViewControllerTransitioningDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "QuickMode" {
            let toViewController = segue.destinationViewController as! UINavigationController
            toViewController.transitioningDelegate = self
            customPresentAnimationController.animationType = CustomSegueAnimation.SwipeDown
            customDismissAnimationController.animationType = CustomSegueAnimation.SwipeDown
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customPresentAnimationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customDismissAnimationController
    }
}