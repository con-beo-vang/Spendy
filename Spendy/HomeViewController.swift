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
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var formatter = NSDateFormatter()
    
    let dayCountInMonth = 30
    
    var incomes = [String]()
    var expenses = [String]()
    
    var isCollapedIncome = true
    var isCollapedExpense = true
    
    var viewMode = ViewMode.Monthly
    
    var weekIndex = 0
    var monthIndex = 0
    var yearIndex = 0
    
    
    var fromDate: NSDate?
    var toDate: NSDate?
    
    let oneDay:Double = 60 * 60 * 24
    
    var downSwipe: UISwipeGestureRecognizer!
    
    let customPresentAnimationController = CustomPresentAnimationController()
    let customDismissAnimationController = CustomDismissAnimationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        settingStatusBar()
        
        navigationItem.title = getTodayString("MMMM")
        let tapTitle = UITapGestureRecognizer(target: self, action: Selector("chooseMode:"))
        navigationController?.navigationBar.addGestureRecognizer(tapTitle)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        viewModeTableView.dataSource = self
        viewModeTableView.delegate = self
        viewModeTableView.tableFooterView = UIView()
        
        addGestures()
        
        incomes = ["Salary", "Bonus", "Salary", "Bonus", "Salary", "Bonus"]
        expenses = ["Meal", "Drink", "Transport",  "Meal", "Drink", "Transport"]
        
        // set current month as default
        let (begin, end) = getMonth(0)
        fromDate = begin
        toDate = end.dateByAddingTimeInterval(oneDay)
        
        // TODO: set data for table view based on fromDate and toDate
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // set top constraint again after presenting new view controller (Quick add)
        let myConstraintTop =
        NSLayoutConstraint(item: statusBarView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 75)
        view.addConstraint(myConstraintTop)

        
        configPopup()
        setColor()
        let gotTutorial = NSUserDefaults.standardUserDefaults().boolForKey("GotTutorial") ?? false
        
        if !gotTutorial {
            goToTutorial()
        }
        
        viewModeTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        settingStatusBar()
    }
    
    func setColor() {
        statusBarView.backgroundColor = Color.lightStatusColor
        currentBarView.backgroundColor = Color.darkStatusColor
        todayLabel.textColor = Color.dateHomeColor
        
        // Date popup
        datePopup.backgroundColor = Color.popupBackgroundColor
        fromLabel.textColor = Color.popupFromColor
        toLabel.textColor = Color.popupFromColor
        fromButton.setTitleColor(Color.popupDateColor, forState: UIControlState.Normal)
        toButton.setTitleColor(Color.popupDateColor, forState: UIControlState.Normal)
        cancelButton.setTitleColor(Color.popupDateColor, forState: UIControlState.Normal)
        doneButton.setTitleColor(Color.popupDateColor, forState: UIControlState.Normal)
        
        Helper.sharedInstance.setPopupShadowAndColor(viewModePopup, label: viewModeTitleLabel)
        Helper.sharedInstance.setPopupShadowAndColor(datePopup, label: dateTitleLabel)
    }
    
    func addGestures() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        leftSwipe.direction = .Left
        leftSwipe.delegate = self
        tableView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        rightSwipe.direction = .Right
        rightSwipe.delegate = self
        tableView.addGestureRecognizer(rightSwipe)
        
        downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        downSwipe.direction = .Down
        downSwipe.delegate = self
        
        if (tableView.contentSize.height <= tableView.frame.size.height) {
            tableView.scrollEnabled = false
            tableView.addGestureRecognizer(downSwipe)
        }
    }
    
    func goToTutorial() {
        let presentationController: TutorialViewController = {
            return TutorialViewController(pages: [])
            }()
        
        presentViewController(presentationController, animated: true, completion: nil)
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
    
    func configPopup() {
        
        formatter.dateFormat = "MM-dd-yyyy"
        
        popupSuperView.hidden = true
        popupSuperView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        let today = NSDate()
        fromButton.setTitle(formatter.stringFromDate(today), forState: UIControlState.Normal)
        toButton.setTitle(formatter.stringFromDate(today), forState: UIControlState.Normal)
    }
    
    // MARK: Button
    
    @IBAction func onFromButton(sender: UIButton) {
        
        formatter.dateFormat = "MM-dd-yyyy"
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
        
        formatter.dateFormat = "MM-dd-yyyy"
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
        
        formatter.dateFormat = "MM-dd-yyyy"
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

// MARK: - Table view

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
            cell.contentView.backgroundColor = Color.popupBackgroundColor
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
            cell.iconView.setNewTintColor(Color.strongColor)
            
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
            
        } else {
            
            let dummyCell = UITableViewCell()
            
            switch indexPath.section {
            case 0:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
                    
                    cell.menuLabel.textColor = Color.incomeColor
                    cell.amountLabel.textColor = Color.incomeColor
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
                    
                    cell.menuLabel.textColor = Color.expenseColor
                    cell.amountLabel.textColor = Color.expenseColor
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
                cell.titleLabel.textColor = Color.balanceColor
                cell.amountLabel.textColor = Color.balanceColor
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
                let (beginWeek, endWeek) = getWeek(weekIndex)
                
                if beginWeek != nil && endWeek != nil {
                    navigationItem.title = getWeekText(beginWeek!, endWeek: endWeek!)
                }
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

// MARK: - Handle gesture

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Left:
            switch viewMode {
            case ViewMode.Weekly:
                weekIndex += 1
                handleSwipeWeek()
            case ViewMode.Monthly:
                monthIndex += 1
                handleSwipeMonth()
            case ViewMode.Yearly:
                yearIndex += 1
                handleSwipeYear()
            default:
                return
            }
            
            // TODO: set data for table view based on fromDate and toDate
            tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 3)), withRowAnimation: UITableViewRowAnimation.Left)
            
            break
        case UISwipeGestureRecognizerDirection.Right:
            switch viewMode {
            case ViewMode.Weekly:
                weekIndex -= 1
                handleSwipeWeek()
            case ViewMode.Monthly:
                monthIndex -= 1
                handleSwipeMonth()
            case ViewMode.Yearly:
                yearIndex -= 1
                handleSwipeYear()
            default:
                return
            }
            
            // TODO: set data for table view based on fromDate and toDate
            tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 3)), withRowAnimation: UITableViewRowAnimation.Right)
            break
            
        case UISwipeGestureRecognizerDirection.Down:
            //            let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("QuickVC") as! QuickViewController
            //            let nc = UINavigationController(rootViewController: dvc)
            //            self.presentViewController(nc, animated: true, completion: nil)
            performSegueWithIdentifier("QuickMode", sender: self)
            
        default:
            return
        }
    }
    
    func tapIncome(sender: UITapGestureRecognizer) {
        if isCollapedIncome {
            isCollapedIncome = false
        } else {
            isCollapedIncome = true
        }
        
        tableView.reloadDataWithBlock { () -> () in
            self.configDownSwipeGesture()
        }
    }
    
    func tapExpense(sender: UITapGestureRecognizer) {
        if isCollapedExpense {
            isCollapedExpense = false
        } else {
            isCollapedExpense = true
        }
        
        tableView.reloadDataWithBlock { () -> () in
            self.configDownSwipeGesture()
        }
    }
    
    func tapMode(sender: UITapGestureRecognizer) {
        let selectedCell = Helper.sharedInstance.getCellAtGesture(sender, tableView: viewModeTableView)
        if let selectedCell = selectedCell {
            let indexPath = viewModeTableView.indexPathForCell(selectedCell)
            
            switch indexPath!.row {
            case 0:
                viewMode = ViewMode.Weekly
                let (beginWeek, endWeek) = getWeek(weekIndex)
                
                if beginWeek != nil && endWeek != nil {
                    navigationItem.title = getWeekText(beginWeek!, endWeek: endWeek!)
                }
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
    
    func configDownSwipeGesture() {
        if (self.tableView.contentSize.height <= self.tableView.frame.size.height) {
            self.tableView.scrollEnabled = false
            self.tableView.addGestureRecognizer(self.downSwipe)
        } else {
            self.tableView.scrollEnabled = true
            self.tableView.removeGestureRecognizer(self.downSwipe)
        }
    }
}

// MARK: - Custom transition

extension HomeViewController: UIViewControllerTransitioningDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "QuickMode" {
            let toViewController = segue.destinationViewController as! UINavigationController
            toViewController.transitioningDelegate = self
            customPresentAnimationController.animationType = CustomSegueAnimation.SwipeDown
            customDismissAnimationController.animationType = CustomSegueAnimation.SwipeDown
            
            let quickVC = toViewController.topViewController as? QuickViewController
            quickVC!.delegate = self
            
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customPresentAnimationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customDismissAnimationController
    }
}

// MARK: - Handle date

extension HomeViewController {
    
    func getWeek(weekIndex: Int) -> (NSDate?, NSDate?) {
        
        var beginningOfWeek: NSDate?
        var endOfWeek: NSDate?
        
        let cal = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.weekOfYear = weekIndex
        
        if let date = cal.dateByAddingComponents(components, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0)) {
            var weekDuration = NSTimeInterval()
            if cal.rangeOfUnit(NSCalendarUnit.WeekOfYear, startDate: &beginningOfWeek, interval: &weekDuration, forDate: date) {
                endOfWeek = beginningOfWeek?.dateByAddingTimeInterval(weekDuration)
            }
            
            beginningOfWeek = cal.dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: beginningOfWeek!, options: NSCalendarOptions(rawValue: 0))
            
        }
        
        return (beginningOfWeek!, endOfWeek!)
    }
    
    func getMonth(monthIndex: Int) -> (NSDate, NSDate) {
        // monthIndex = -1: previous month
        // monthIndex = 0: current month
        // monthIndex = 1: next month
        
        let calendar = NSCalendar.currentCalendar()
        
        // Create an NSDate for the first and last day of the month
        let components = calendar.components(NSCalendarUnit.Month, fromDate: NSDate())
        
        // Get suitable month
        components.month += monthIndex
        
        // Getting the First and Last date of the month
        components.day = 1
        let firstDateOfMonth: NSDate = calendar.dateFromComponents(components)!
        
        components.month += 1
        components.day = 0
        let lastDateOfMonth: NSDate = calendar.dateFromComponents(components)!
        
        return (firstDateOfMonth, lastDateOfMonth)
    }
    
    func getYear(yearIndex: Int) -> (NSDate, NSDate) {
        
        let calendar = NSCalendar.currentCalendar()
        
        // Create an NSDate for the first and last day of the month
        let components = calendar.components(NSCalendarUnit.Year, fromDate: NSDate())
        
        // Get suitable month
        components.year += yearIndex
        
        // Getting the First and Last date of the month
        components.day = 1
        let firstDateOfYear: NSDate = calendar.dateFromComponents(components)!
        
        components.year += 1
        components.day = 0
        let lastDateOfYear: NSDate = calendar.dateFromComponents(components)!
        
        return (firstDateOfYear, lastDateOfYear)
    }
    
    func handleSwipeWeek() {
        
        let (beginWeek, endWeek) = getWeek(weekIndex)
        if beginWeek != nil && endWeek != nil {
            navigationItem.title = getWeekText(beginWeek!, endWeek: endWeek!)
        }
        fromDate = beginWeek
        toDate = endWeek?.dateByAddingTimeInterval(oneDay)
    }
    
    func handleSwipeMonth() {
        
        let (beginMonth, endMonth) = getMonth(monthIndex)
        fromDate = beginMonth
        toDate = endMonth.dateByAddingTimeInterval(oneDay)
        formatter.dateFormat = "MMMM"
        navigationItem.title = formatter.stringFromDate(beginMonth)
        
        // TODO: Explain about fromDate and toDate
        
        // beginMonth and endMonth are at the begin of day (time: 12:00:00)
        // so set toDate = endMonth + 1 day
        // create a method to get transaction between 2 dates
        // fromDate <= transaction's date < toDate
        
        // remove these code when clear about fromDate and toDate
        formatter.dateFormat = "MM-dd-yyyy hh:mm:ss"
        print(formatter.stringFromDate(fromDate!))
        print(formatter.stringFromDate(toDate!))
    }
    
    func handleSwipeYear() {
        let (beginYear, endYear) = getYear(yearIndex)
        fromDate = beginYear
        toDate = endYear.dateByAddingTimeInterval(oneDay)
        formatter.dateFormat = "yyyy"
        navigationItem.title = formatter.stringFromDate(beginYear)
    }
    
    func getWeekText(beginWeek: NSDate, endWeek: NSDate) -> String {
        formatter.dateFormat = "dd MMM"
        return formatter.stringFromDate(beginWeek) + " - " + formatter.stringFromDate(endWeek)
    }
    
    func getTodayString(dateFormat: String) -> String {
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(NSDate())
    }
}

extension HomeViewController: QuickViewControllerDelegate {
    
    func quickViewController(quickViewController: QuickViewController, didAddTransaction status: Bool) {
        if status {
            print("delegate")
            tabBarController?.selectedIndex = 1
            let accountsNVC = tabBarController?.viewControllers?.at(1) as? UINavigationController
            let accountsVC = accountsNVC?.topViewController as? AccountsViewController
            accountsVC?.isFromQuickAdd = true
        }
    }
}
