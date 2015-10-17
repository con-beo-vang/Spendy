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
    
    @IBOutlet weak var statusBarTopConstraint: NSLayoutConstraint!
    
    
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

    var balanceStat: BalanceStat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBalanceStats", name: SPNotification.balanceStatsUpdated, object: nil)
        
        // Set color for inactive icon in tab bar
        for item in (tabBarController?.tabBar.items as [UITabBarItem]?)! {
            if let image = item.image {
                item.image = image.imageWithColor(Color.inactiveTabBarIconColor).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
//        settingStatusBar()
        
        navigationItem.title = DateFormatter.MMMM.stringFromDate(NSDate())
        let tapTitle = UITapGestureRecognizer(target: self, action: Selector("chooseMode:"))
        navigationController?.navigationBar.addGestureRecognizer(tapTitle)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        viewModeTableView.dataSource = self
        viewModeTableView.delegate = self
        viewModeTableView.tableFooterView = UIView()
        
        addGestures()
        
        // set current month as default
        let (begin, end) = getMonth(0)
        fromDate = begin
        toDate = end.dateByAddingTimeInterval(oneDay)
        
        print("from: \(DateFormatter.E_MMM_dd_yyyy.stringFromDate(fromDate!))")
        print("to: \(DateFormatter.E_MMM_dd_yyyy.stringFromDate(toDate!))")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // If user taps Change on reminder notificaiton, go to Quick Add
        if NSUserDefaults.standardUserDefaults().boolForKey("GoToQuickAdd") {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "GoToQuickAdd")
            performSegueWithIdentifier("QuickMode", sender: self)
        }
        
        // set top constraint again after presenting new view controller (Quick add)
        if statusBarTopConstraint != nil {
            view.removeConstraint(statusBarTopConstraint)
        }
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

        reloadDateRange()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        settingStatusBar()
    }

    func reloadDateRange() {
        if let fromDate = fromDate, toDate = toDate {
            // tableView will be updated asynchronously via balanceStatUpdated notification
            balanceStat = BalanceStat(from: fromDate, to: toDate)
        } else {
            tableView.reloadData()
        }
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
        
        todayLabel.text = DateFormatter.MMMM_dd_yyyy.stringFromDate(NSDate())
        
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
        
        popupSuperView.hidden = true
        popupSuperView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        let today = NSDate()
        fromButton.setTitle(DateFormatter.MM_dd_yyyy.stringFromDate(today), forState: UIControlState.Normal)
        toButton.setTitle(DateFormatter.MM_dd_yyyy.stringFromDate(today), forState: UIControlState.Normal)
    }
    
    // MARK: Button
    
    @IBAction func onFromButton(sender: UIButton) {
        
        let defaultDate = DateFormatter.MM_dd_yyyy.dateFromString((sender.titleLabel?.text)!)
        
        DatePickerDialog().show(title: "From Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: defaultDate!, minDate: nil, datePickerMode: .Date) {
            (date) -> Void in
            print(date, terminator: "\n")
            
            let dateString = DateFormatter.MM_dd_yyyy.stringFromDate(date)
            print("formated: \(dateString)", terminator: "\n")
            sender.setTitle(dateString, forState: UIControlState.Normal)
            
            let currentToDate = DateFormatter.MM_dd_yyyy.dateFromString((self.toButton.titleLabel?.text)!)
            if currentToDate < date {
                self.toButton.setTitle(DateFormatter.MM_dd_yyyy.stringFromDate(date), forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func onToButton(sender: UIButton) {
        let defaultDate = DateFormatter.MM_dd_yyyy.dateFromString((sender.titleLabel?.text)!)
        let minDate = DateFormatter.MM_dd_yyyy.dateFromString((fromButton.titleLabel?.text)!)
        
        DatePickerDialog().show(title: "To Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: defaultDate!, minDate: minDate, datePickerMode: .Date) {
            (date) -> Void in
            print("DatePickerDialog: \(date)")
            
            let dateString = DateFormatter.MM_dd_yyyy.stringFromDate(date)
            print("formated: \(dateString)")
            sender.setTitle(dateString, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func onDoneDatePopup(sender: UIButton) {
        
        let formatter1 = DateFormatter.MM_dd_yyyy
        fromDate = formatter1.dateFromString((fromButton.titleLabel!.text)!)
        toDate = formatter1.dateFromString((toButton.titleLabel!.text)!)
        
        print("from: \(DateFormatter.E_MMM_dd_yyyy.stringFromDate(fromDate!))")
        print("to: \(DateFormatter.E_MMM_dd_yyyy.stringFromDate(toDate!))")
        
        reloadDateRange()
        tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 3)), withRowAnimation: UITableViewRowAnimation.Automatic)
        
        let formater2 = DateFormatter.MMM_dd_yyyy
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
                    if let total = balanceStat?.incomeTotal {
                        cell.amountLabel.text = Transaction.currencyFormatter.stringFromNumber(total)
                    }
                    
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

                    let name = incomes[indexPath.row - 1]
                    cell.categoryLabel.text = name
                    if let amount = balanceStat.groupedIncomeCategories?[name] {
                        cell.amountLabel.text   = Transaction.currencyFormatter.stringFromNumber(amount)
                    }
                    
                    return cell
                }
                
            case 1:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
                    
                    cell.menuLabel.textColor = Color.expenseColor
                    cell.amountLabel.textColor = Color.expenseColor
                    cell.menuLabel.text = "Expense"
                    if let total = balanceStat?.expenseTotal {
                        cell.amountLabel.text = Transaction.currencyFormatter.stringFromNumber(total)
                    }
                    
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

                    let name = expenses[indexPath.row - 1]
                    cell.categoryLabel.text = name
                    if let amount = balanceStat.groupedExpenseCategories?[name] {
                        cell.amountLabel.text   = Transaction.currencyFormatter.stringFromNumber(amount)
                    }
                    
                    return cell
                }
                
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("BalanceCell", forIndexPath: indexPath) as! BalanceCell
                cell.titleLabel.textColor = Color.balanceColor
                cell.amountLabel.textColor = Color.balanceColor
                if let balanceTotal = balanceStat.balanceTotal {
                    cell.amountLabel.text = Transaction.currencyFormatter.stringFromNumber(balanceTotal)
                }
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
                
                fromDate = beginWeek
                toDate = endWeek?.dateByAddingTimeInterval(oneDay)
                
                break
            case 1:
                viewMode = ViewMode.Monthly
                
                let (beginMonth, endMonth) = getMonth(monthIndex)
                fromDate = beginMonth
                toDate = endMonth.dateByAddingTimeInterval(oneDay)
                
                navigationItem.title = DateFormatter.MMMM.stringFromDate(beginMonth)
                break
            case 2:
                viewMode = ViewMode.Yearly
                
                let (beginYear, endYear) = getYear(yearIndex)
                fromDate = beginYear
                toDate = endYear.dateByAddingTimeInterval(oneDay)
                
                navigationItem.title = DateFormatter.yyyy.stringFromDate(beginYear)
                break
            case 3:
                viewMode = ViewMode.Custom
                viewModeTableView.reloadData()
                showPopup(datePopup)
                return
            default:
                return
            }
            reloadDateRange()
            viewModeTableView.reloadData()
            
            print("from: \(DateFormatter.E_MMM_dd_yyyy.stringFromDate(fromDate!))")
            print("to: \(DateFormatter.E_MMM_dd_yyyy.stringFromDate(toDate!))")
            
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
            reloadDateRange()
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
            reloadDateRange()
            tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 3)), withRowAnimation: UITableViewRowAnimation.Right)
            break
            
        case UISwipeGestureRecognizerDirection.Down:
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
                navigationItem.title = DateFormatter.MMMM.stringFromDate(NSDate())
                break
            case 2:
                viewMode = ViewMode.Yearly
                // get today's string
                navigationItem.title = DateFormatter.yyyy.stringFromDate(NSDate())
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
            
            // Custom transaction's animation
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
        let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: NSDate())
        
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
        navigationItem.title = DateFormatter.MMMM.stringFromDate(beginMonth)
        
        // TODO: Explain about fromDate and toDate
        
        // beginMonth and endMonth are at the begin of day (time: 12:00:00)
        // so set toDate = endMonth + 1 day
        // create a method to get transaction between 2 dates
        // fromDate <= transaction's date < toDate
        
        // remove these code when clear about fromDate and toDate
        print(DateFormatter.MM_dd_yyyy_hh_mm_ss.stringFromDate(fromDate!))
        print(DateFormatter.MM_dd_yyyy_hh_mm_ss.stringFromDate(toDate!))
    }
    
    func handleSwipeYear() {
        let (beginYear, endYear) = getYear(yearIndex)
        fromDate = beginYear
        toDate = endYear.dateByAddingTimeInterval(oneDay)
        navigationItem.title = DateFormatter.yyyy.stringFromDate(beginYear)
    }
    
    func getWeekText(beginWeek: NSDate, endWeek: NSDate) -> String {
        return DateFormatter.dd_MMMM.stringFromDate(beginWeek) + " - " + DateFormatter.dd_MMMM.stringFromDate(endWeek)
    }
}

// MARK: - Implement delegate

extension HomeViewController: QuickViewControllerDelegate {
    
    func quickViewController(quickViewController: QuickViewController, didAddTransaction status: Bool) {
        if status {
            print("quickView delegate")
            tabBarController?.selectedIndex = 1
            let accountsNVC = tabBarController?.viewControllers?.at(1) as? UINavigationController
            let accountsVC = accountsNVC?.topViewController as? AccountsViewController
            accountsVC?.justAddTransactions = true
            accountsVC?.addedAccount = RAccount.defaultAccount()
        }
    }
}


// MARK: - BalanceStat callbacks

extension HomeViewController {
    func updateBalanceStats() {
        if let groupedExpenses = balanceStat.groupedExpenseCategories {
            expenses = Array(groupedExpenses.keys).sort { groupedExpenses[$0] > groupedExpenses[$1] }
        }

        if let groupedIncomes = balanceStat.groupedIncomeCategories {
            incomes = Array(groupedIncomes.keys).sort { groupedIncomes[$0] > groupedIncomes[$1] }
        }

        tableView.reloadData()
    }
}