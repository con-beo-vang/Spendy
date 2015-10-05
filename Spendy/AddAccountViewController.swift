//
//  AddAccountViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/26/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class AddAccountViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var addButton: UIButton?
    var backButton: UIButton?
    
    var datePickerIsShown = false

    var account: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tabBarController != nil {
            tabBarController!.tabBar.hidden = true
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        addBarButton()

    }

    override func viewWillAppear(animated: Bool) {
        // TODO: Why is this not working?
        if let nameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! TextCell? {
            nameCell.textField.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button
    
    func addBarButton() {
        
        addButton = UIButton()
        Helper.sharedInstance.customizeBarButton(self, button: addButton!, imageName: "Bar-Tick", isLeft: false)
        addButton!.addTarget(self, action: "onAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        backButton = UIButton()
        Helper.sharedInstance.customizeBarButton(self, button: backButton!, imageName: "Bar-Back", isLeft: true)
        backButton!.addTarget(self, action: "onBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    func updateFieldsForAccount() -> Bool {
        if account == nil {
            // adding an account

            // validating inputs
            let nameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! TextCell
            let startBalanceCell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! TextCell

            guard let name = nameCell.textField.text, balanceString = startBalanceCell.textField.text else {
                return false
            }

            var startingBalance = NSDecimalNumber(string: balanceString)
            if startingBalance == NSDecimalNumber.notANumber() {
                startingBalance = 0
            }
            account = Account(name: name, startingBalance: startingBalance)

            Account.create(account!)

            NSNotificationCenter.defaultCenter().postNotificationName(SPNotification.accountAddedOrUpdated, object: nil, userInfo: ["account": account!])
        } else {
            // TODO: editing an account?
        }

        return true
    }

    func onAddButton(sender: UIButton!) {
        print("on Add", terminator: "\n")
        // TODO: create new account
        guard updateFieldsForAccount() else {
            let alertController = UIAlertController(title: "Please enter a name :)", message: nil, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)

            presentViewController(alertController, animated: true) {}

            return
        }

        self.tabBarController?.tabBar.hidden = false
        navigationController?.popViewControllerAnimated(true)
    }
    
    func onBackButton(sender: UIButton!) {
        self.tabBarController?.tabBar.hidden = false
        navigationController?.popViewControllerAnimated(true)
    }
}

// MARK: Transfer between 2 views

extension AddAccountViewController: SelectAccountOrCategoryDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toController = segue.destinationViewController
        
        if toController is SelectAccountOrCategoryViewController {
            let vc = toController as! SelectAccountOrCategoryViewController
            
            let cell = sender as! SelectAccountOrCategoryCell
            vc.itemClass = cell.itemClass
            vc.delegate = self
            
            // TODO: delegate
        }
    }
    
    func selectAccountOrCategoryViewController(selectAccountOrCategoryController: SelectAccountOrCategoryViewController, selectedItem item: AnyObject, selectedType type: String?) {
        if item is Account {
            // TODO: set selected acocunt for current account's type
            // selectedTransaction!.account = (item as! Account)
            tableView.reloadData()
        }
    }
}

extension AddAccountViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ((indexPath.section == 1 && datePickerIsShown) ? 195 : 44)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dummyCell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath) as! TextCell
            
            if indexPath.row == 0 {
                cell.label.text = "Name"
                cell.textField.placeholder = "Account name"
            } else {
                cell.label.text = "Start Balance"
                cell.textField.keyboardType = .DecimalPad
            }
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("DateCell", forIndexPath: indexPath) as! DateCell
            
            let today = NSDate()
            cell.dateLabel.text = DateFormatter.EEE_MMM_dd_yyyy.stringFromDate(today)
            
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("SelectAccountOrCategoryCell", forIndexPath: indexPath) as! SelectAccountOrCategoryCell
            cell.itemClass = "Account"
            cell.titleLabel.text = "Type"
            cell.typeLabel.text = "Other"
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            return cell
            
        default:
            break
        }
        
        return dummyCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            datePickerIsShown = !datePickerIsShown
            tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}
