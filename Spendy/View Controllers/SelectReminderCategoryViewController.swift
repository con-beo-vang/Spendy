//
//  SelectReminderCategoryViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/30/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class SelectReminderCategoryViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  var items: [Category]?
  
  var backButton: UIButton?
  
  // MARK: - Main functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addBarButton()
    items = Category.allExpenseType()
    tableView.tableFooterView = UIView()
    tableView.reloadData()
  }
  
  // MARK: Button
  
  func addBarButton() {
    backButton = UIButton()
    Helper.sharedInstance.customizeBarButton(self, button: backButton!, imageName: "Bar-Back", isLeft: true)
    backButton!.addTarget(self, action: "onBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
  }
  
  func onBackButton(sender: UIButton!) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let cell = sender as! CategoryCell
    let indexPath = tableView.indexPathForCell(cell)
    
    let toController = segue.destinationViewController
    
    if toController is AddReminderViewController {
      let vc = toController as! AddReminderViewController
      
      let category:Category = items![indexPath!.row]
      vc.selectedUserCategory = UserCategory.findByCategoryId(category.id)
      
      vc.isNewReminder = true
    }
  }
  
}

// MARK: - Table view

extension SelectReminderCategoryViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 56
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
    
    if let item = items?[indexPath.row] {
      cell.nameLabel.text = item["name"] as! String?
      
      if let icon = item["icon"] as? String {
        
        cell.iconImageView.image = Helper.sharedInstance.createIcon(icon)
        cell.iconImageView.setNewTintColor(UIColor.whiteColor())
        cell.iconImageView.layer.backgroundColor = Color.expenseColor.CGColor
      }
    }
    
    cell.setSeparatorFullWidth()
    return cell
  }
  
}
