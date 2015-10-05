//
//  AccountsViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/17/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import SCLAlertView

class AccountsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var addAccountButton: UIButton?
    
    var accounts: [Account]?
    
    var isPreparedDelete = false
    var moneyIcon: UIImageView?
    var initialIconCenter: CGPoint?
    var selectedDragCell: AccountCell?
    var previousCell: AccountCell?
    
    // Popup
    
    @IBOutlet weak var popupSuperView: UIView!
    
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var amountText: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var transferButton: UIButton!
    
    var justAddTransactions = false
    var addedAccount: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.delegate = self
        
        tabBarItem.image = UIImage(named: "InactiveAccount")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        accounts = Account.all
        tableView.reloadData()
        
        if (tableView.contentSize.height <= tableView.frame.size.height) {
            tableView.scrollEnabled = false
        }
        else {
            tableView.scrollEnabled = true
        }
        
        addBarButton()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAccountList:", name: SPNotification.accountAddedOrUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAccountList:", name: SPNotification.transactionsLoadedForAccount, object: nil)
    }

    func updateAccountList(notification: NSNotification) {
        print("[Notified][AccountsViewController:updateAccountList")
        accounts = Account.all
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if justAddTransactions {
            performSegueWithIdentifier("GoToAccountDetail", sender: self)
        }
        
        tableView.reloadData()
        configPopup()
        setColor()
    }
    
    // MARK: Button
    
    func addBarButton() {
        
        addAccountButton = UIButton()
        Helper.sharedInstance.customizeBarButton(self, button: addAccountButton!, imageName: "Bar-AddAccount", isLeft: false)
        addAccountButton!.addTarget(self, action: "onAddAccountButton:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onAddAccountButton(sender: UIButton!) {
        print("on Add account")
        performSegueWithIdentifier("AddAccount", sender: self)
    }
    
    // MARK: Popup
    
    func configPopup() {
        
        popupSuperView.hidden = true
        popupSuperView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        amountText.keyboardType = UIKeyboardType.DecimalPad
        
        Helper.sharedInstance.setPopupShadowAndColor(popupView, label: titleLabel)
    }
    
    func setColor() {
        popupView.backgroundColor = Color.popupBackgroundColor
        cancelButton.setTitleColor(Color.popupButtonColor, forState: UIControlState.Normal)
        transferButton.setTitleColor(Color.popupButtonColor, forState: UIControlState.Normal)
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
        addAccountButton?.enabled = false
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
                    self.addAccountButton?.enabled = true
                }
        });
    }
    
    @IBAction func onCancelButton(sender: UIButton) {
        closePopup()
    }
    
    @IBAction func onTransferButton(sender: UIButton) {
        // TODO: Handle transfer
        let amountString = (amountText.text)!
        
        if amountString.isEmpty {
            let alertController = UIAlertController(title: "Please enter an amount.", message: nil, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true) {}
        } else {
            let amountDecimal = NSDecimalNumber(string: amountString)
            let fromAccount = selectedDragCell?.account
            let toAccount = previousCell?.account
            print("transfer from \(fromAccount?.name) to \(toAccount?.name)")
            
            let transaction = Transaction(kind: Transaction.transferKind, note: "", amount: amountDecimal, category: Category.defaultTransferCategory(), account: fromAccount, date: NSDate())
            transaction.toAccount = toAccount
            Transaction.add(transaction)
            tableView.reloadData()
            
            closePopup()
        }
    }
    
    @IBAction func onAmountChanged(sender: UITextField) {
        Helper.sharedInstance.preventInputManyDots(sender)
    }
    
    // MARK: Transfer between 2 views
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue to AccountDetailView!", terminator: "\n")

        // It is more natural to just push from tableview cell directly to the detail view
        // It is still possible to add navigation control to the view
        if segue.identifier == "GoToAccountDetail" {
            let accountDetailVC = segue.destinationViewController as! AccountDetailViewController
            
            if justAddTransactions {
                justAddTransactions = false
                accountDetailVC.currentAccount = addedAccount
                self.tabBarController?.tabBar.hidden = false
            } else {
                let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
                accountDetailVC.currentAccount = accounts![indexPath.row]
            }
        }
    }
    
}

// MARK: Table View

extension AccountsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell", forIndexPath: indexPath) as! AccountCell

        cell.account = accounts![indexPath.row]

        if !hasPanGesture(cell) {
            print("adding pan for cell \(indexPath.row)")
            let panGesture = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
            panGesture.delegate = self
            cell.addGestureRecognizer(panGesture)
        }
        
        Helper.sharedInstance.setSeparatorFullWidth(cell)
        return cell
    }
    
    func hasPanGesture(cell: UITableViewCell) -> Bool {
        if let gestures = cell.gestureRecognizers {
            for gesture in gestures {
                if gesture is UIPanGestureRecognizer {
                    return true
                }
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        print("action", terminator: "\n")
        isPreparedDelete = true
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("Delete account:")
            
            let alertController = UIAlertController(title: "Warning", message: "Deleting Saving will cause to also delete its transactions.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Default) { (action) in
                if let accountToDelete = self.accounts?[indexPath.row] {
                    self.accounts?.removeAtIndex(indexPath.row)
                    Account.delete(accountToDelete)
                }

                // reload the entire table
                // tableView.reloadData()
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            alertController.addAction(deleteAction)
            
            self.presentViewController(alertController, animated: true) {}
        }
        delete.backgroundColor = UIColor.redColor()

        return [delete]
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        print("didEndEditingRowAtIndexPath", terminator: "\n")
        isPreparedDelete = false
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // empty
    }
}

// MARK: Handle gestures

extension AccountsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        selectedDragCell = sender.view as? AccountCell
        
        if let selectedDragCell = selectedDragCell {
//            var indexPath = tableView.indexPathForCell(selectedDragCell)

            selectedDragCell.backgroundColor = Color.originalAccountColor
            
            
            let translation = sender.translationInView(tableView)
            let state = sender.state
            
            switch state {
            case UIGestureRecognizerState.Began:
                print("began")
                
                moneyIcon = UIImageView(image: UIImage(named: "MoneyBag"))
                moneyIcon?.setNewTintColor(Color.strongColor)
                moneyIcon!.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                moneyIcon!.userInteractionEnabled = true
                
                tableView.addSubview(moneyIcon!)
                
                moneyIcon!.center = sender.locationInView(tableView)
                initialIconCenter = moneyIcon?.center
                break
                
            case UIGestureRecognizerState.Changed:
                print("change")
                
                if !isPreparedDelete {
                    moneyIcon!.center.x = initialIconCenter!.x + translation.x
                    moneyIcon!.center.y = initialIconCenter!.y + translation.y
                    
                    // Highlight the destination cell
                    let cell = getContainAccountCell(moneyIcon!.center)
                    if cell != selectedDragCell {
                        if cell != previousCell {
                            previousCell?.backgroundColor = UIColor.clearColor()
                            if let cell = cell {
                                cell.backgroundColor = Color.destinationAccountColor
                                cell.typeLabel.textColor = UIColor.whiteColor()
                            }
                            
                            previousCell = cell
                        }
                    } else {
                        if previousCell != selectedDragCell {
                            previousCell?.backgroundColor = UIColor.clearColor()
                            previousCell?.typeLabel.textColor = UIColor.lightGrayColor()
                        }
                        previousCell = cell
                    }
                }
                break
                
            case UIGestureRecognizerState.Ended:
                print("end")
                
                moneyIcon?.removeFromSuperview()
                selectedDragCell.backgroundColor = UIColor.clearColor()
                previousCell?.backgroundColor = UIColor.clearColor()
                previousCell?.typeLabel.textColor = UIColor.lightGrayColor()
                
                if previousCell != selectedDragCell && !isPreparedDelete {
                    
                    amountText.text = ""
                    let fromAcc = selectedDragCell.nameLabel.text ?? ""
                    let toAcc = previousCell?.nameLabel.text ?? ""
                    
                    if !fromAcc.isEmpty && !toAcc.isEmpty {
                        messageLabel.text = "Transfer from \(fromAcc) to \(toAcc)"
                        showPopup()
                    }
                }
                break
                
            default:
                break
            }
        }
        
    }
    
    func getContainAccountCell(point: CGPoint) -> AccountCell? {
        var indexPathSet = [NSIndexPath]()
        
        for index in 0..<accounts!.count {
            indexPathSet.append(NSIndexPath(forRow: index, inSection: 0))
        }
        
        for indexPath in indexPathSet {
            let rect = tableView.rectForRowAtIndexPath(indexPath)
            if rect.contains(point) {
                return tableView.cellForRowAtIndexPath(indexPath) as? AccountCell
            }
        }
        return nil
    }
}
