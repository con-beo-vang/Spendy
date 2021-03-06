//
//  AccountDetailViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/18/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var createdDateLabel: UILabel!
  
  @IBOutlet weak var startingBalanceLabel: UILabel!
  
  var addButton: UIButton?
  var cancelButton: UIButton?
  
  // Used to display transactions of the same month in the same section
  // Each section header is the first transaction's month
  var accountTransactions: [[Transaction]]!
  
  var currentAccount: Account!
  
  var refreshControl: UIRefreshControl?
  
  // MARK: - Main functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // create a few sample transactions
    reloadTransactions()
    
    tableView.tableFooterView = UIView()
    
    addBarButton()
    addRefreshControl()
    setNotification()
  }
  
  func addRefreshControl() {
    // Add tip for open Wuick mode
    self.refreshControl = UIRefreshControl()
    self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to open Quick mode")
    self.refreshControl!.addTarget(self, action: "openQuickMode", forControlEvents: UIControlEvents.ValueChanged)
    self.tableView.addSubview(refreshControl!)
  }
  
  func setNotification() {
    // observe so we can switch account if necessary
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentAccount:", name: SPNotification.transactionAddedOrUpdated, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable:", name: SPNotification.recomputedBalanceForOneAccount, object: nil)
  }
  
  func refreshTable(notification: NSNotification) {
    print("[Notified][AccountDetailViewController:refreshTable]")
    reloadTransactions()
    tableView.reloadData()
  }
  
  func updateCurrentAccount(notification: NSNotification) {
    // First try to cast user info to expected type
    guard let info = notification.userInfo as? Dictionary<String,AnyObject> else {
      print("[updateCurrentAccount] Cannot cast userInfo \(notification.userInfo)")
      return
    }
    
    guard let updatedAccount = info["account"] as! Account? else { return }
    
    // switch to the updated account
    currentAccount = updatedAccount
    BalanceComputing.recompute(currentAccount)
  }
  
  func reloadTransactions() {
    accountTransactions = TransactionGrouping.listGroupedByMonth(Array(currentAccount.sortedTransactions))
  }
  
  // reload data after we navigate back from pushed cell
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let currentAccount = currentAccount {
      navigationItem.title = currentAccount.name
      
      createdDateLabel.text = "Created on: \(DateFormatter.MM_dd_yyyy.stringFromDate(currentAccount.createdAt))"
      startingBalanceLabel.text = "Starting balance: $\(currentAccount.startingBalance)"
    }
    
    print("viewWillAppear", terminator: "\n")
    reloadTransactions()
    tableView.reloadData()
  }
  
  func openQuickMode() {
    refreshControl?.endRefreshing()
    let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("QuickVC") as! QuickViewController
    let nc = UINavigationController(rootViewController: dvc)
    self.presentViewController(nc, animated: true, completion: nil)
  }
  
  // MARK: Button
  
  func addBarButton() {
    addButton = UIButton()
    Helper.sharedInstance.customizeBarButton(self, button: addButton!, imageName: "Bar-Add", isLeft: false)
    addButton!.addTarget(self, action: "onAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
    
    cancelButton = UIButton()
    Helper.sharedInstance.customizeBarButton(self, button: cancelButton!, imageName: "Bar-Cancel", isLeft: true)
    cancelButton!.addTarget(self, action: "onCancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
  }
  
  func onAddButton(sender: UIButton!) {
    let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("AddVC") as! AddTransactionViewController
    dvc.currentAccount = currentAccount
    let nc = UINavigationController(rootViewController: dvc)
    self.presentViewController(nc, animated: true, completion: nil)
  }
  
  func onCancelButton(sender: UIButton!) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK: Transfer between 2 views
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let vc = segue.destinationViewController
    
    if vc is AddTransactionViewController {
      let addTransactionViewController = vc as! AddTransactionViewController
      
      var indexPath: AnyObject!
      indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
      
      addTransactionViewController.selectedTransaction = accountTransactions[indexPath.section][indexPath.row]
      print("pass selectedTransaction to AddTransactionView: \(addTransactionViewController.selectedTransaction))", terminator: "\n")
    }
  }
  
}

// MARK: - Table view

extension AccountDetailViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return accountTransactions.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return accountTransactions[section].count
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 30))
    headerView.backgroundColor = UIColor(netHex: 0xDCDCDC)
    
    let monthLabel = UILabel(frame: CGRect(x: 8, y: 2, width: UIScreen.mainScreen().bounds.width - 16, height: 30))
    monthLabel.font = UIFont.systemFontOfSize(14)
    
    monthLabel.text = accountTransactions[section].first?.monthHeader()
    
    headerView.addSubview(monthLabel)
    
    return headerView
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 34
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 62
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TransactionCell", forIndexPath: indexPath) as! TransactionCell
    // must set current account before transaction
    // it could be a fromAccount or toAccount
    // this is the only way to find out
    cell.currentAccount = currentAccount
    cell.transaction = accountTransactions[indexPath.section][indexPath.row]
    
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
    rightSwipe.direction = .Right
    cell.addGestureRecognizer(rightSwipe)
    
    let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
    leftSwipe.direction = .Left
    cell.addGestureRecognizer(leftSwipe)
    
    cell.setSeparatorFullWidth()
    return cell
  }
  
}

// MARK: - Handle gestures

extension AccountDetailViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func handleSwipe(sender: UISwipeGestureRecognizer) {
    let selectedCell = sender.view as! TransactionCell
    
    guard let indexPath = tableView.indexPathForCell(selectedCell) else {
      print("can't find indexPath for cell \(selectedCell)")
      return
    }
    
    let swipedTransaction = accountTransactions[indexPath.section][indexPath.row]
    
    switch sender.direction {
    case UISwipeGestureRecognizerDirection.Left:
      // Delete transaction
      swipedTransaction.remove()
      
      reloadTransactions()
      
      // OPTIMIZE: check if section still exists, if yes, load it
      // However it's not worth it. Just reload the whole thing
      tableView.reloadData()
      break
      
    case UISwipeGestureRecognizerDirection.Right:
      // duplicate to a new transaction today
      let newTransaction = swipedTransaction.clone()
      newTransaction.date = NSDate()
      newTransaction.save()
      
      reloadTransactions()
      tableView.reloadData()
      break
      
    default:
      break
    }
  }
  
  func handleDownSwipe(sender: UISwipeGestureRecognizer) {
    if sender.direction == .Down {
      let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("QuickVC") as! QuickViewController
      let nc = UINavigationController(rootViewController: dvc)
      self.presentViewController(nc, animated: true, completion: nil)
    }
  }
  
}
