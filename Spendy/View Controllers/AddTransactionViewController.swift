//
//  AddViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import PhotoTweaks
import Parse

class AddTransactionViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var addImageView: UIImageView!
  
  var addButton: UIButton?
  var cancelButton: UIButton?
  
  var isCollaped = true
  var datePickerIsShown = false
  
  var noteCell: NoteCell?
  var amountCell: AmountCell?
  var categoryCell: SelectAccountOrCategoryCell?
  var accountCell: SelectAccountOrCategoryCell?
  var toAccountCell: SelectAccountOrCategoryCell?
  var dateCell: DateCell?
  var photoCell: PhotoCell?
  
  var oldPhoto: UIImage?
  var oldPhotoIsSet = false
  var oldAmountIsSet = false
  
  var selectedTransaction: Transaction?
  var currentAccount: Account!
  
  var imagePicker: UIImagePickerController!
  
  // remember the selected category under each transaction kind
  var backupCategories = [String : Category?]()
  var backupAccounts   = [String : Account? ]()
  
  var validationErrors = [String]()
  
  // MARK: - Main functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tabBarController?.tabBar.hidden = true
    tableView.tableFooterView = UIView()
    
    isCollaped = true
    
    addBarButton()
    setupAddImageView()
    
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if currentAccount == nil {
      currentAccount = Account.defaultAccount()
    }
    
    if let transaction = selectedTransaction {
      if transaction.isNew() {
        navigationItem.title = "Add Transaction"
        oldPhotoIsSet = false
        oldAmountIsSet = false
        view.endEditing(true)
      } else {
        navigationItem.title = "Edit Transaction"
        // Get the old photo to set in PhotoCell
        if !transaction.localPhotoPath.isEmpty {
          if let photo = UIImage(contentsOfFile: transaction.localPhotoPath) {
            oldPhoto = photo
          }
        }
      }
    } else {
      // TODO: add a convenience contructor to Transaction
      selectedTransaction = Transaction()
      selectedTransaction!.kind = CategoryType.Expense.rawValue
      selectedTransaction!.category = Category.defaultCategoryFor(.Expense)
      selectedTransaction!.fromAccount = currentAccount
      selectedTransaction!.date = NSDate()
      // TODO: replace with a good default amount
      //            selectedTransaction!.amount = 10
      isCollaped = true
      oldPhotoIsSet = false
      oldAmountIsSet = false
    }
    
    tableView.reloadData()
    
    // Change button's color based on strong color
    Helper.sharedInstance.setIconLayer(addImageView)
  }
  
  func setupAddImageView() {
    addImageView.image = Helper.sharedInstance.createIcon("Bar-Tick")
    let tapGesture = UITapGestureRecognizer(target: self, action: "onAddImageTapped:")
    addImageView.addGestureRecognizer(tapGesture)
  }
  
  func onAddImageTapped(sender: UITapGestureRecognizer) {
    handleAddTransaction()
  }
  
  func updateFieldsToTransaction() -> Bool {
    validationErrors = []
    
    if let transaction = self.selectedTransaction {
      transaction.update { t in
        t.note = self.noteCell?.noteText.text
        t.kind = CategoryType.allValueStrings[self.amountCell!.typeSegment.selectedSegmentIndex]
        t.amountDecimal = NSDecimalNumber(string: self.amountCell?.amountText.text)
        
        if t.amount == 0 {
          self.validationErrors.append("Please enter an amount")
        }
        
        // TODO: validate date is in the past
        if let date = self.dateCell?.datePicker.date {
          t.date = date
          print("setting date to transaction: \(date)")
        }
        
        // Save photo to document directory
        if let photoCell = self.photoCell, photo = photoCell.photoView.image {
          if photo != self.oldPhoto {
            let oldPhotoPath = t.localPhotoPath
            // Create photo name based on current date time
            let filename = "\(DateFormatter.yyyyMMddhhmmss.stringFromDate(NSDate())).jpg"
            let email = PFUser.currentUser()?.email
            if Helper.savePhotoLocal(photo, email: email!, filename: filename) {
              t.localPhotoName = filename
              if !oldPhotoPath.isEmpty {
                Helper.deleteOldPhoto(oldPhotoPath)
              }
              print("saved photo")
            }
          }
        }
      }
    }
    
    if let transaction = selectedTransaction {
      if transaction.isTransfer() {
        if transaction.toAccount == nil {
          validationErrors.append("Please specifiy To Account:")
        } else if transaction.toAccount?.id == transaction.fromAccount?.id {
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
    handleAddTransaction()
  }
  
  func handleAddTransaction() {
    // check if we can update fields
    // show errors if can't
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
    
    guard let transaction = selectedTransaction else {
      print("Error: selectedTransaction is nil")
      return
    }
    
    print("[onAddButton] transaction: \(transaction)")
    
    // TODO: add transaction and update both fromAccount and toAccount stats
    // - save transaction to database
    // - view must know about the transaction in the parent account (fromAccount, and maybe toAccount if it's a transfer)
    transaction.save()
    
    print("posting notification TransactionAddedOrUpdated")
    NSNotificationCenter.defaultCenter().postNotificationName("TransactionAddedOrUpdated", object: nil, userInfo: ["account": transaction.fromAccount!])
    
    if let toAccount = transaction.toAccount {
      NSNotificationCenter.defaultCenter().postNotificationName("TransactionAddedOrUpdated", object: nil, userInfo: ["account": toAccount])
    }
    
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
    accountsVC?.addedAccount = selectedTransaction?.fromAccount
    
    selectedTransaction = nil
  }
  
  func onCancelButton(sender: UIButton!) {
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

// MARK: - Transfer between 2 views

extension AddTransactionViewController: SelectAccountOrCategoryDelegate, PhotoViewControllerDelegate {
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    updateFieldsToTransaction()
    
    // Dismiss all keyboard and datepicker
    view.endEditing(true)
    hideDatePicker(hidden: true)
    
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
        selectedTransaction!.update { $0.toAccount = (item as! Account) }
      } else {
        selectedTransaction!.update { $0.fromAccount = (item as! Account) }
      }
      
      tableView.reloadData()
    } else if item is Category {
      selectedTransaction!.update {$0.category = (item as! Category) }
      
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

// MARK: - Table View

extension AddTransactionViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return isCollaped ? 3 : 4
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 2
    case 1:
      if selectedTransaction != nil && selectedTransaction!.isTransfer() {
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
    return ((indexPath.section == 2 && datePickerIsShown) ? 182 : 40)
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
        
        if !cell.hasTapGesture() {
          let tapCell = UITapGestureRecognizer(target: self, action: "tapNoteCell:")
          cell.addGestureRecognizer(tapCell)
        }
        
        cell.setSeparatorFullWidth()
        if noteCell == nil {
          noteCell = cell
        }
        return cell
        
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("AmountCell", forIndexPath: indexPath) as! AmountCell
        
        // Set old amount in the first time loading this cell
        if !oldAmountIsSet {
          cell.amountText.text = selectedTransaction!.isNew() ? "" : selectedTransaction!.amountDecimal?.stringValue
          oldAmountIsSet = true
        }
        
        cell.amountText.keyboardType = UIKeyboardType.DecimalPad
        cell.setSeparatorFullWidth()
        
        if amountCell == nil {
          amountCell = cell
          
          // Only add gesture recognizer once
          cell.typeSegment.addTarget(self, action: "typeSegmentChanged:", forControlEvents: UIControlEvents.ValueChanged)
          print("Added typeSegmentChanged gesture. Should only do once")
          
          if !cell.hasTapGesture() {
            let tapCell = UITapGestureRecognizer(target: self, action: "tapAmoutCell:")
            cell.addGestureRecognizer(tapCell)
            print("Added tapAmountCell gesture")
          }
        }
        
        // TODO refactor into AmountCell
        guard let transaction = selectedTransaction,
          segmentIndex = CategoryType.allValueStrings.indexOf(transaction.kind!),
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
        
        cell.setSeparatorFullWidth()
        
        if categoryCell == nil {
          categoryCell = cell
        }
        return cell
        
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectAccountOrCategoryCell", forIndexPath: indexPath) as! SelectAccountOrCategoryCell
        
        cell.itemClass = "Account"
        
        print("kind: \(selectedTransaction!.kind)")
        if selectedTransaction!.isTransfer() {
          cell.fromAccount = selectedTransaction!.fromAccount
        } else {
          cell.account = selectedTransaction!.fromAccount
        }
        
        cell.setSeparatorFullWidth()
        
        if accountCell == nil {
          accountCell = cell
        }
        return cell
        
      case 2:
        // Only for Transfer category type
        guard let category = selectedTransaction!.category where category.isTransfer() else { break }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectAccountOrCategoryCell", forIndexPath: indexPath) as! SelectAccountOrCategoryCell
        
        cell.itemClass = "Account"
        cell.toAccount = selectedTransaction!.toAccount
        
        cell.setSeparatorFullWidth()
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ViewMoreCell", forIndexPath: indexPath) as! ViewMoreCell
        
        cell.titleLabel.textColor = Color.moreDetailColor
        
        if !cell.hasTapGesture() {
          let tapCell = UITapGestureRecognizer(target: self, action: "tapMoreCell:")
          cell.addGestureRecognizer(tapCell)
        }
        
        cell.setSeparatorFullWidth()
        return cell
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("DateCell", forIndexPath: indexPath) as! DateCell
        cell.titleLabel.text = "Date"
        cell.delegate = self
        
        let date = selectedTransaction!.date ?? NSDate()
        cell.datePicker.date = date
        cell.dateLabel.text = DateFormatter.E_MMM_dd_yyyy.stringFromDate(date)
        
        if !cell.hasTapGesture() {
          let tapCell = UITapGestureRecognizer(target: self, action: "tapDateCell:")
          cell.addGestureRecognizer(tapCell)
        }
        
        cell.datePicker.alpha = datePickerIsShown ? 1 : 0
        cell.setSeparatorFullWidth()
        
        // override previous datecell with this datecell with datepicker
        dateCell = cell
        
        return cell
      }
      
    case 3:
      let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
      
      // Set old photo in the first time loading this cell
      if !oldPhotoIsSet {
        if let oldPhoto = oldPhoto {
          cell.photoView.image = oldPhoto
        } else {
          cell.photoView.image = nil
        }
        oldPhotoIsSet = true
      }
      
      cell.setSeparatorFullWidth()
      if photoCell == nil {
        photoCell = cell
      }
      return cell
      
    default:
      break
    }
    
    return dummyCell
  }
  
  @IBAction func onAmountChanged(sender: UITextField) {
    sender.preventInputManyDots()
  }
  
}

// MARK: - Handle gestures

extension AddTransactionViewController {
  
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
    view.endEditing(true)
    hideDatePicker(hidden: datePickerIsShown)
  }
  
  func typeSegmentChanged(sender: UISegmentedControl) {
    updateFieldsToTransaction()
    
    // back up category choice for each segment value
    // so that when we switch back, it can be resumed
    let newType = CategoryType.allValues[sender.selectedSegmentIndex]
    
    if let oldCategory = selectedTransaction!.category {
      backupCategories[oldCategory.type!] = oldCategory
    }
    
    // set new category
    selectedTransaction!.category = backupCategories[newType.rawValue] ?? Category.defaultCategoryFor(newType)
    
    if newType == .Transfer {
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

// MARK: - UIImagePickerController

extension AddTransactionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      
      let photoTweaksViewController = PhotoTweaksViewController(image: pickedImage)
      photoTweaksViewController.autoSaveToLibray = false
      photoTweaksViewController.delegate = self
      imagePicker.pushViewController(photoTweaksViewController, animated: true)
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}

// MARK: - Photo Tweaks

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

// MARK: - Handle date picker

extension AddTransactionViewController: DateCellDelegate {
  
  func dateCell(dateCell: DateCell, selectedDate: NSDate) {
    selectedTransaction!.date = selectedDate
    hideDatePicker(hidden: true)
  }
  
  func hideDatePicker(hidden hidden: Bool) {
    datePickerIsShown = !hidden
    tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Automatic)
  }
  
}
