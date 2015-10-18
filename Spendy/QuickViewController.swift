//
//  QuickViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

@objc protocol QuickViewControllerDelegate {
    optional func quickViewController(quickViewController: QuickViewController, didAddTransaction status: Bool)
}

class QuickViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var popupSuperView: UIView!

    @IBOutlet weak var popupView: UIView!

    @IBOutlet weak var popupTitleLabel: UILabel!

    @IBOutlet weak var amountText: UITextField!

    @IBOutlet weak var cancelPopupButton: UIButton!

    @IBOutlet weak var donePopupButton: UIButton!

    @IBOutlet weak var primaryButton: UIButton!

    var addButton: UIButton?
    var cancelButton: UIButton?

//    var commonTracsations = [String]() // transaction object

    var selectedIndexPath: NSIndexPath?
    var oldSelectedSegmentIndex: Int?

    weak var delegate: QuickViewControllerDelegate?

    var userCategories: [RUserCategory]!
    var quickTransactions: [RTransaction]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load top user categories
        userCategories = RUserCategory.allForQuickAdd()

        quickTransactions = userCategories.map({ (userCat) -> RTransaction in
            let defaultAmount = userCat.quickAddAmounts().first

            return RTransaction(kind: CategoryType.Expense.rawValue, note: nil, amountDecimal: defaultAmount!, category: userCat.category!, account: Account.defaultAccount(), date: NSDate())
        })

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        // Swipe up to close Quick mode
        if (tableView.contentSize.height <= tableView.frame.size.height) {
            tableView.scrollEnabled = false

            let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
            swipeUp.direction = .Up
            swipeUp.delegate = self
            tableView.addGestureRecognizer(swipeUp)
        }

        addBarButton()

        configPopup()

    }

    override func viewWillAppear(animated: Bool) {
        setColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setColor() {
        primaryButton.backgroundColor = Color.strongColor
        primaryButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        primaryButton.layer.cornerRadius = 5
        primaryButton.layer.masksToBounds = true

        popupView.backgroundColor = Color.popupBackgroundColor
        cancelPopupButton.setTitleColor(Color.popupButtonColor, forState: UIControlState.Normal)
        donePopupButton.setTitleColor(Color.popupButtonColor, forState: UIControlState.Normal)
    }

    // MARK: Button

    func addBarButton() {

        addButton = UIButton()
        Helper.sharedInstance.customizeBarButton(self, button: addButton!, imageName: "Bar-Tick", isLeft: false)
        addButton!.addTarget(self, action: "onAddButton:", forControlEvents: UIControlEvents.TouchUpInside)

        cancelButton = UIButton()
        Helper.sharedInstance.customizeBarButton(self, button: cancelButton!, imageName: "Bar-Cancel", isLeft: true)
        cancelButton!.addTarget(self, action: "onCancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    func onAddButton(sender: UIButton!) {
        addQuickTransactions()
    }

    func onCancelButton(sender: UIButton!) {
        delegate?.quickViewController!(self, didAddTransaction: false)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onPrimaryButton(sender: UIButton) {
        addQuickTransactions()
    }

    func addQuickTransactions() {
        print("Add transactions")
        for (index, transaction) in quickTransactions.enumerate() {
            let cell = tableView.cellForRowAtIndexPath( NSIndexPath(forRow: index, inSection: 0) ) as! QuickCell
            let segment = cell.amoutSegment
            let amountText = segment.titleForSegmentAtIndex(segment.selectedSegmentIndex)
            transaction.amountDecimal = NSDecimalNumber(string: amountText)
            transaction.save()
//            Transaction.add(transaction)
        }

        delegate?.quickViewController!(self, didAddTransaction: true)
        dismissViewControllerAnimated(false, completion: nil)
    }


    // MARK: Popup

    func configPopup() {

        popupSuperView.hidden = true
        popupSuperView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)

        amountText.keyboardType = UIKeyboardType.DecimalPad

        Helper.sharedInstance.setPopupShadowAndColor(popupView, label: popupTitleLabel)
    }

    @IBAction func onCancelPopup(sender: UIButton) {

        amountText.text = ""

        // TODO: set selected segment depending on object's value
        let cell = tableView.cellForRowAtIndexPath(selectedIndexPath!) as! QuickCell
        cell.amoutSegment.selectedSegmentIndex = oldSelectedSegmentIndex!
        closePopup()
    }

    @IBAction func onDonePopup(sender: UIButton) {

        if let selectedIndexPath = selectedIndexPath {
            let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as! QuickCell
            if !amountText.text!.isEmpty {
                cell.amoutSegment.setTitle(amountText.text, forSegmentAtIndex: 3)
                amountText.text = ""
                oldSelectedSegmentIndex = 3
            } else {
                if cell.amoutSegment.titleForSegmentAtIndex(3) == "Other" {
                    // TODO: set selected segment depending on object's value
                    cell.amoutSegment.selectedSegmentIndex = oldSelectedSegmentIndex!
                } else {
                    oldSelectedSegmentIndex = 3
                }
            }
        }

        closePopup()
    }
    
    @IBAction func onAmountChanged(sender: UITextField) {
        Helper.sharedInstance.preventInputManyDots(sender)
    }
    
    

    func showPopup() {

        popupSuperView.hidden = false
        popupView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        popupView.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.popupView.alpha = 1.0
            self.popupView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });

        amountText.becomeFirstResponder()

        // Disable bar button
        addButton?.enabled = false
        cancelButton?.enabled = false
    }

    func closePopup() {

        UIView.animateWithDuration(0.25, animations: {
            self.popupView.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.popupView.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.popupSuperView.hidden = true
                self.amountText.resignFirstResponder()

                // enable bar button
                self.addButton?.enabled = true
                self.cancelButton?.enabled = true
            }
        });
    }

}

// MARK: Table view

extension QuickViewController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quickTransactions.count
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 30))
        headerView.backgroundColor = UIColor(netHex: 0xDCDCDC)

        if section == 0 {
            let accountLabel = UILabel(frame: CGRect(x: 8, y: 2, width: UIScreen.mainScreen().bounds.width - 16, height: 30))
            accountLabel.font = UIFont.systemFontOfSize(14)

            accountLabel.text = "* Add transactions to \((Account.defaultAccount().name)!)"

            headerView.addSubview(accountLabel)
        }
        return headerView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("QuickCell", forIndexPath: indexPath) as! QuickCell

        cell.amountValues = userCategories[indexPath.row].quickAddAmounts()
        cell.transaction = quickTransactions[indexPath.row]

        cell.amoutSegment.addTarget(self, action: "amountSegmentChanged:", forControlEvents: UIControlEvents.ValueChanged)

        // Swipe left to delete this row
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        leftSwipe.direction = .Left
        cell.addGestureRecognizer(leftSwipe)

        Helper.sharedInstance.setSeparatorFullWidth(cell)

        return cell
    }

    func amountSegmentChanged(sender: UISegmentedControl) {
        print("touch \(sender)")

        let segment = sender as! CustomSegmentedControl
        oldSelectedSegmentIndex = segment.oldValue

        // show popup if Other is tapped
        if sender.selectedSegmentIndex == 3 {
            let selectedCell = sender.superview?.superview as! QuickCell
            let indexPath = tableView.indexPathForCell(selectedCell)
            selectedIndexPath = indexPath
            showPopup()
        }
    }

    // MARK: Handle gestures
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func handleSwipe(sender:UISwipeGestureRecognizer) {

        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Left:
            let selectedCell = sender.view as! QuickCell
            let indexPath = tableView.indexPathForCell(selectedCell)
            quickTransactions.removeAtIndex(indexPath!.row)
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)

            if quickTransactions.count == 0 {
                dismissViewControllerAnimated(true, completion: nil)
            }
            break

        case UISwipeGestureRecognizerDirection.Up:
            dismissViewControllerAnimated(true, completion: nil)
            break

        default:
            break
        }
    }
}
