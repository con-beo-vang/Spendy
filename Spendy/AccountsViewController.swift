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
    
//    let customNavigationAnimationController = CustomNavigationAnimationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        accounts = Account.all()
        tableView.reloadData()
        
        if (tableView.contentSize.height <= tableView.frame.size.height) {
            tableView.scrollEnabled = false
        }
        else {
            tableView.scrollEnabled = true
        }
        
        addBarButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: Button
    
    func addBarButton() {
        
        addAccountButton = UIButton()
        Helper.sharedInstance.customizeBarButton(self, button: addAccountButton!, imageName: "Bar-AddAccount", isLeft: false)
        addAccountButton!.addTarget(self, action: "onAddAccountButton:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onAddAccountButton(sender: UIButton!) {
        print("on Add account", terminator: "\n")
        performSegueWithIdentifier("AddAccount", sender: self)
    }
    
    // MARK: Transfer between 2 views
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue to AccountDetailView!", terminator: "\n")

        // It is more natural to just push from tableview cell directly to the detail view
        // It is still possible to add navigation control to the view
        if segue.identifier == "GoToAccountDetail" {
            let accountDetailVC = segue.destinationViewController as! AccountDetailViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            accountDetailVC.currentAccount = accounts![indexPath.row]
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
            print("delete", terminator: "\n")
            let alertView = SCLAlertView()
            alertView.addButton("Delete", action: { () -> Void in
                self.accounts?.removeAtIndex(indexPath.row)
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                // TODO: Delete this account and its transactions
            })
            
            alertView.showWarning("Warning", subTitle: "Deleting Saving will cause to also delete its transactions.", closeButtonTitle: "Cancel", colorStyle: 0x55AEED, colorTextButton: 0xFFFFFF)
            
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
                print("began", terminator: "\n")
                
                moneyIcon = UIImageView(image: UIImage(named: "MoneyBag"))
                moneyIcon?.setNewTintColor(Color.strongColor)
                moneyIcon!.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                moneyIcon!.userInteractionEnabled = true
                
                tableView.addSubview(moneyIcon!)
                
                moneyIcon!.center = sender.locationInView(tableView)
                initialIconCenter = moneyIcon?.center
                break
                
            case UIGestureRecognizerState.Changed:
                print("change", terminator: "\n")
                
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
                print("end", terminator: "\n")
                
                moneyIcon?.removeFromSuperview()
                selectedDragCell.backgroundColor = UIColor.clearColor()
                previousCell?.backgroundColor = UIColor.clearColor()
                previousCell?.typeLabel.textColor = UIColor.lightGrayColor()
                
                if previousCell != selectedDragCell && !isPreparedDelete {
                    
                    let fromAcc = selectedDragCell.nameLabel.text ?? ""
                    let toAcc = previousCell?.nameLabel.text ?? ""
                    
                    if !fromAcc.isEmpty && !toAcc.isEmpty {
                        let alert = SCLAlertView()
                        let txt = alert.addAmoutField("Enter the amount")
                        alert.addButton("Transfer") {
                            print("Amount value: \(txt.text)", terminator: "\n")
                        }
                        alert.showEdit("Transfer", subTitle: "Transfer from \(fromAcc) account to \(toAcc) account", closeButtonTitle: "Cancel", colorStyle: 0x55AEED, colorTextButton: 0xFFFFFF)
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

// MARK: Custom transition

//extension AccountsViewController: UINavigationControllerDelegate {
//    
//    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
////        if operation == .Push {
////            
////            customInteractionController.attachToViewController(toVC)
////        }
//        customNavigationAnimationController.reverse = operation == .Pop
//        return customNavigationAnimationController
//    }
//}
