//
//  AddViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import PhotoTweaks

class AddTransactionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var addButton: UIButton?
    var cancelButton: UIButton?
    
    var isCollaped = true
    var isShowDatePicker = false
    
    var noteCell: NoteCell?
    var amountCell: AmountCell?
    var categoryCell: SelectAccountOrCategoryCell?
    var accountCell: SelectAccountOrCategoryCell?
    var toAccountCell: SelectAccountOrCategoryCell?
    var dateCell: DateCell?
    var photoCell: PhotoCell?
    
    var selectedTransaction: Transaction?

    var imagePicker: UIImagePickerController!

    var currentAccount: Account!

    // remember the selected category under each transaction kind
    var backupCategories = [String:Category?]()
    var backupAccounts   = [String:Account?]()

    var validationErrors = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        isCollaped = true
        
        addBarButton()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if currentAccount == nil {
            currentAccount = Account.defaultAccount()
        }
        
        if let transaction = selectedTransaction {
            if !transaction.isNew() {
                navigationItem.title = "Edit Transaction"
            } else {
                navigationItem.title = "Add Transaction"
            }
        } else {
            selectedTransaction = Transaction(kind: Transaction.expenseKind,
                note: nil, amount: nil,
                category: Category.defaultExpenseCategory(), account: currentAccount,
                date: NSDate())
            isCollaped = true
        }
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateFieldsToTransaction() -> Bool {
        validationErrors = []

        if let transaction = selectedTransaction {
            transaction.note = noteCell?.noteText.text
            transaction.kind = Transaction.kinds[amountCell!.typeSegment.selectedSegmentIndex]

            let amountDecimal = NSDecimalNumber(string: amountCell?.amountText.text)
            if amountDecimal != NSDecimalNumber.notANumber() {
                transaction.amount = amountDecimal
            } else {
               validationErrors.append("Please enter an amount")
            }

            // TODO: parse date
            // validate date is in the past
            if let date = dateCell?.datePicker.date {
                transaction.date = date
                print("date: \(date)")
            }


            if transaction.kind == Transaction.transferKind {
                if transaction.toAccount == nil {
                    validationErrors.append("Please specifiy To Account:")
                } else if transaction.toAccount?.objectId == transaction.fromAccount?.objectId {
                    validationErrors.append("From and To accounts must be different")
                }
            }
        }

        return validationErrors.isEmpty
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
        // update fields
        guard updateFieldsToTransaction() else {
            let nextError = validationErrors.first!

            let alertController = UIAlertController(title: nextError, message: nil, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)

            presentViewController(alertController, animated: true) {}

            return
        }

        guard let transaction = selectedTransaction else { print("Error: selectedTransaction is nil")
            return
        }

        print("[onAddButton] transaction: \(transaction)")

        if transaction.isNew() {
            // add transaction and update both fromAccount and toAccount stats
            Transaction.add(transaction)
        } else {
            transaction.save()
        }

        print("posting notification TransactionAddedOrUpdated")
        NSNotificationCenter.defaultCenter().postNotificationName("TransactionAddedOrUpdated", object: nil, userInfo: ["account": transaction.fromAccount!])

        closeView()
    }

    func closeTabAndSwitchToHome() {
        // unhide the tabBar because we hid it for the Add tab
        self.tabBarController?.tabBar.hidden = false
        let rootVC = parentViewController?.parentViewController as? RootTabBarController
        // go to Accouns tab
        rootVC?.selectedIndex = 1
        
        let accountsNVC = rootVC?.viewControllers?.at(1) as? UINavigationController
        let accountsVC = accountsNVC?.topViewController as? AccountsViewController
        accountsVC?.justAddTransactions = true
        accountsVC?.addedAccount = Account.findById((selectedTransaction?.fromAccountId)!)
        
        selectedTransaction = nil
    }

    func onCancelButton(sender: UIButton!) {
        print("onCancelButton", terminator: "\n")
        closeView()
    }

    func closeView() {
        switch presentingViewController {
        case is AccountDetailViewController, is RootTabBarController:
            print("exiting modal from \(presentingViewController)")
            dismissViewControllerAnimated(true, completion: nil)

        default:
            guard navigationController != nil else {
                print("Error closing view: \(self)")
                return
            }

            // exit push
            navigationController!.popViewControllerAnimated(true)
        }

        
        closeTabAndSwitchToHome()
    }
}

// MARK: Transfer between 2 views

extension AddTransactionViewController: SelectAccountOrCategoryDelegate, PhotoViewControllerDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        updateFieldsToTransaction()
        
        // Dismiss all keyboard and datepicker
        noteCell?.noteText.resignFirstResponder()
        amountCell?.amountText.resignFirstResponder()
        dateCell?.datePicker.alpha = 0
        
        let toController = segue.destinationViewController
        
        if toController is SelectAccountOrCategoryViewController {
            let vc = toController as! SelectAccountOrCategoryViewController
            
            let cell = sender as! SelectAccountOrCategoryCell

            vc.itemClass = cell.itemClass
            vc.itemTypeFilter = cell.itemTypeFilter

            vc.delegate = self
            
            if cell.itemClass == "Category" {
                vc.selectedItem = selectedTransaction!.category
            } else {
                if cell.itemTypeFilter == "ToAccount" {
                    vc.selectedItem = selectedTransaction!.toAccount
                } else {
                    vc.selectedItem = selectedTransaction!.fromAccount
                }
            }
            
            // TODO: delegate
        } else if toController is PhotoViewController {
            
            let photoCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as? PhotoCell
            if let photoCell = photoCell {
                if photoCell.photoView.image == nil {
                    Helper.sharedInstance.showActionSheet(self, imagePicker: imagePicker)
                } else {
                    let photoVC = toController as! PhotoViewController
                    photoVC.selectedImage = photoCell.photoView.image
                    photoVC.delegate = self
                }
            }
        }
    }
    
    func selectAccountOrCategoryViewController(selectAccountOrCategoryController: SelectAccountOrCategoryViewController, selectedItem item: AnyObject, selectedType type: String?) {
        if item is Account {
            if let type = type where type == "ToAccount" {
                selectedTransaction!.toAccount = (item as! Account)
            } else {
                selectedTransaction!.fromAccount = (item as! Account)
            }

            tableView.reloadData()
        } else if item is Category {
            selectedTransaction!.category = (item as! Category)

            tableView.reloadData()
        } else {
            print("Error: item is \(item)")
        }
    }
    
    func photoViewController(photoViewController: PhotoViewController, didUpdateImage image: UIImage) {
        let photoCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as? PhotoCell
        if let photoCell = photoCell {
            photoCell.photoView.image = image
        }
    }
}

// MARK: Table View

extension AddTransactionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return isCollaped ? 3 : 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            if selectedTransaction?.kind == Transaction.transferKind {
                // 3 rows:
                // Category (fixed as Transfer)
                // From Account
                // To Account
                return 3
            } else {
                // 2 rows:
                // Category
                // Account
                return 2
            }
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ((indexPath.section == 2 && isShowDatePicker) ? 182 : 40)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 30))
        headerView.backgroundColor = UIColor(netHex: 0xDCDCDC)
        
        if section == 0 {
            let todayLabel = UILabel(frame: CGRect(x: 8, y: 2, width: UIScreen.mainScreen().bounds.width - 16, height: 30))
            todayLabel.font = UIFont.systemFontOfSize(14)
            
            let today = NSDate()
            todayLabel.text = DateFormatter.fullStyle.stringFromDate(today)
            
            headerView.addSubview(todayLabel)
        }
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 2 ? 0 : 34
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let dummyCell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! NoteCell
                
                cell.noteText.text = selectedTransaction?.note
                
                let tapCell = UITapGestureRecognizer(target: self, action: "tapNoteCell:")
                cell.addGestureRecognizer(tapCell)
                
                Helper.sharedInstance.setSeparatorFullWidth(cell)
                if noteCell == nil {
                    noteCell = cell
                }
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("AmountCell", forIndexPath: indexPath) as! AmountCell
                
                cell.amountText.text = selectedTransaction?.amount?.stringValue
                cell.amountText.keyboardType = UIKeyboardType.DecimalPad

                Helper.sharedInstance.setSeparatorFullWidth(cell)

                if amountCell == nil {
                    amountCell = cell

                    // only add gesture recognizers once
                    cell.typeSegment.addTarget(self, action: "typeSegmentChanged:", forControlEvents: UIControlEvents.ValueChanged)
                    print("Added typeSegmentChanged gesture. Should only do once")
                    let tapCell = UITapGestureRecognizer(target: self, action: "tapAmoutCell:")
                    cell.addGestureRecognizer(tapCell)
                    print("Added tapAmountCell gesture")
                }

                // TODO refactor into AmountCell
                guard let transaction = selectedTransaction,
                          segmentIndex = Transaction.kinds.indexOf(transaction.kind!),
                          segment = cell.typeSegment else {
                    return cell
                }

                segment.selectedSegmentIndex = segmentIndex
                switch segmentIndex {
                case 0:
                    segment.tintColor = Color.incomeColor
                case 1:
                    segment.tintColor = Color.expenseColor
                case 2:
                    segment.tintColor = Color.balanceColor
                default:
                    print("Invalid segment index: \(segmentIndex)")
                }

                return cell
                
            default:
                break
            }
            
            break
            
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("SelectAccountOrCategoryCell", forIndexPath: indexPath) as! SelectAccountOrCategoryCell

                cell.itemClass = "Category"
                cell.category = selectedTransaction!.category

                Helper.sharedInstance.setSeparatorFullWidth(cell)
                
                if categoryCell == nil {
                    categoryCell = cell
                }
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("SelectAccountOrCategoryCell", forIndexPath: indexPath) as! SelectAccountOrCategoryCell
                
                cell.itemClass = "Account"

                print("kind: \(selectedTransaction!.kind)")
                if selectedTransaction!.kind == "Transfer" {
                    cell.fromAccount = selectedTransaction!.fromAccount
                } else {
                    cell.account = selectedTransaction!.fromAccount
                }

                Helper.sharedInstance.setSeparatorFullWidth(cell)

                if accountCell == nil {
                    accountCell = cell
                }
                return cell

            case 2:
                // Only for Transfer category type
                guard let category = selectedTransaction!.category where category.type() == "Transfer" else { break }

                let cell = tableView.dequeueReusableCellWithIdentifier("SelectAccountOrCategoryCell", forIndexPath: indexPath) as! SelectAccountOrCategoryCell
                
                cell.itemClass = "Account"
                cell.toAccount = selectedTransaction!.toAccount

                Helper.sharedInstance.setSeparatorFullWidth(cell)

                if toAccountCell == nil {
                    toAccountCell = cell
                }
                return cell

            default:
                break
            }
            
            break
            
        case 2:
            if isCollaped {
                let cell = tableView.dequeueReusableCellWithIdentifier("ViewMoreCell", forIndexPath: indexPath)
                
                let tapCell = UITapGestureRecognizer(target: self, action: "tapMoreCell:")
                cell.addGestureRecognizer(tapCell)
                
                Helper.sharedInstance.setSeparatorFullWidth(cell)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("DateCell", forIndexPath: indexPath) as! DateCell
                cell.titleLabel.text = "Date"
                let date = selectedTransaction!.date ?? NSDate()
                cell.datePicker.date = date
                cell.dateLabel.text = DateFormatter.E_MMM_dd_yyyy.stringFromDate(date)

                let tapCell = UITapGestureRecognizer(target: self, action: "tapDateCell:")
                cell.addGestureRecognizer(tapCell)
                
                if isShowDatePicker {
                    cell.datePicker.alpha = 1
                } else {
                    cell.datePicker.alpha = 0
                }
                
                Helper.sharedInstance.setSeparatorFullWidth(cell)

                // override previous datecell with this datecell with datepicker
                dateCell = cell

                return cell
            }
            
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
            Helper.sharedInstance.setSeparatorFullWidth(cell)
            if photoCell == nil {
                photoCell = cell
            }
            return cell
            
        default:
            break
        }
        
        return dummyCell
    }
}

extension AddTransactionViewController {
    // MARK: Handle gestures
    
    func tapNoteCell(sender: UITapGestureRecognizer) {
        noteCell!.noteText.becomeFirstResponder()
    }
    
    func tapAmoutCell(sender: UITapGestureRecognizer) {
        amountCell!.amountText.becomeFirstResponder()
    }
    
    func tapMoreCell(sender: UITapGestureRecognizer) {
        isCollaped = false

        updateFieldsToTransaction()
        
        UIView.transitionWithView(tableView,
            duration:0.5,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations:
            { () -> Void in
                self.tableView.reloadData()
            },
            completion: nil)
    }
    
    func tapDateCell(sender: UITapGestureRecognizer) {
        noteCell!.noteText.resignFirstResponder()
        amountCell!.amountText.resignFirstResponder()
        
        if isShowDatePicker {
            isShowDatePicker = false
            tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Automatic)
        } else {
            isShowDatePicker = true
            tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func typeSegmentChanged(sender: UISegmentedControl) {
        updateFieldsToTransaction()

        // back up category choice for each segment value
        // so that when we switch back, it can be resumed
        let newType = ["Income", "Expense", "Transfer"][sender.selectedSegmentIndex]

        if let oldCategory = selectedTransaction!.category {
            backupCategories[oldCategory.type()!] = oldCategory
        }

        // set new category
        selectedTransaction!.category = backupCategories[newType] ?? Category.defaultCategoryFor(newType)

        if newType == "Transfer" {
            // reset cached value
            selectedTransaction!.toAccount = backupAccounts["ToAccount"] ?? Account.nonDefaultAccount()
        } else {
            // back up, then nullify
            if let toAccount = selectedTransaction!.toAccount {
                backupAccounts["ToAccount"] = toAccount
            }
            selectedTransaction!.toAccount = nil
        }

        print("transaction: \(selectedTransaction?.description)")

        tableView.reloadData()
    }
}

// MARK: UIImagePickerController

extension AddTransactionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let photoTweaksViewController = PhotoTweaksViewController(image: pickedImage)
            photoTweaksViewController.delegate = self
            imagePicker.pushViewController(photoTweaksViewController, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: Photo Tweaks

extension AddTransactionViewController: PhotoTweaksViewControllerDelegate {
    
    func photoTweaksController(controller: PhotoTweaksViewController!, didFinishWithCroppedImage croppedImage: UIImage!) {
        // Get photo cell
        let photoCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as? PhotoCell
        if let photoCell = photoCell {
            photoCell.photoView.contentMode = .ScaleToFill
            photoCell.photoView.image = croppedImage
        }
        
        controller.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func photoTweaksControllerDidCancel(controller: PhotoTweaksViewController!) {
        controller.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
