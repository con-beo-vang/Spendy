//
//  SettingsViewController.swift
//  Spendy
//
//  Created by Harley Trung on 9/17/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import Parse
import SwiftSpinner

class SettingsViewController: UIViewController, ThemeCellDelegate, UITabBarControllerDelegate {
  
  @IBOutlet weak var avatarView: UIImageView!
  
  @IBOutlet weak var usernameLabel: UILabel!
  
  @IBOutlet weak var emailLabel: UILabel!
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var emailTextField: UITextField!
  
  @IBOutlet weak var saveEmailButton: UIButton!
  
  @IBOutlet weak var logoutButton: UIButton!
  
  let defaultPassword = "defaultPassword"
  
  // temporary
  @IBOutlet weak var accountStatusLabel: UILabel!
  
  @IBOutlet weak var resetDataButton: UIButton!
  
  @IBOutlet weak var avatarTopConstraint: NSLayoutConstraint!
  
  // MARK: - Main functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    tableView.reloadData()
    
    avatarView.setNewTintColor(Color.strongColor)
    
    if let user = PFUser.currentUser() {
      print("user = \(user)")
      usernameLabel.text = (user["name"] as? String) ?? "(No name)"
      emailLabel.text = user.email
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    // set top constraint again after presenting new view controller (Quick add)
    if avatarTopConstraint != nil {
      view.removeConstraint(avatarTopConstraint)
    }
    let myConstraintTop =
    NSLayoutConstraint(item: avatarView,
      attribute: NSLayoutAttribute.Top,
      relatedBy: NSLayoutRelation.Equal,
      toItem: self.view,
      attribute: NSLayoutAttribute.Top,
      multiplier: 1.0,
      constant: 75)
    view.addConstraint(myConstraintTop)
  }
  
  @IBAction func onResetData(sender: AnyObject) {
    resetDataButton.enabled = false
    DataManager.setupDefaultData(true)
  }
  
  func userIsAnonymous() -> Bool {
    let user = PFUser.currentUser()!
    let anonymous = PFAnonymousUtils.isLinkedWithUser(user)
    print("anonymous: \(anonymous)", terminator: "\n")
    return anonymous
  }
  
  // MARK: Button actions
  
  @IBAction func onLogout(sender: UIButton) {
    SwiftSpinner.show("Logging out...")
    PFUser.logOutInBackgroundWithBlock { (error) -> Void in
      SwiftSpinner.hide()
      if let error = error {
        print("Error with logging out: \(error)")
      } else {
        print("Logged out. User: \(PFUser.currentUser())")
        // Transfer to Login view
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
          self.presentViewController(loginVC, animated: true, completion: nil)
        })
      }
    }
  }
  
  // MARK: Implement delegate
  
  func themeCell(themeCell: ThemeCell, didChangeValue value: Bool) {
    Color.isGreen = value
    
    NSUserDefaults.standardUserDefaults().setBool(value, forKey: "DefaultTheme")
    
    self.navigationController?.navigationBar.barTintColor = Color.strongColor
    self.tabBarController!.tabBar.tintColor = Color.strongColor
    
    UINavigationBar.appearance().barTintColor = Color.strongColor
    UITabBar.appearance().tintColor = Color.strongColor
    
    self.viewDidLoad()
  }
  
}

// MARK: - Table view

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
  // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let dummyCell = UITableViewCell()
    
    switch indexPath.row {
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("DefaultAccountCell", forIndexPath: indexPath) as! DefaultAccountCell
      cell.account = Account.defaultAccount()
      return cell
    case 1:
      let cell = tableView.dequeueReusableCellWithIdentifier("NotificationSettingsCell", forIndexPath: indexPath)
      return cell
    case 2:
      let cell = tableView.dequeueReusableCellWithIdentifier("ThemeCell", forIndexPath: indexPath) as! ThemeCell
      cell.delegate = self
      cell.onSwitch.on = Color.isGreen
      cell.onSwitch.onTintColor =  Color.strongColor
      return cell
    case 3:
      let cell = UITableViewCell()
      cell.textLabel?.text = "View Tutorial"
      cell.accessoryType = .DisclosureIndicator
      cell.selectionStyle = .None
      return cell
    case 4:
      let cell = tableView.dequeueReusableCellWithIdentifier("LogOutCell", forIndexPath: indexPath) as! LogOutCell
      cell.logoutButton.setTitleColor(Color.moreDetailColor, forState: UIControlState.Normal)
      return cell
    default:
      break
    }
    
    return dummyCell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.row {
    case 0:
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let selectCategoryVC = storyboard.instantiateViewControllerWithIdentifier("SelectAccountOrCategoryVC") as! SelectAccountOrCategoryViewController
      
      selectCategoryVC.selectedItem = Account.defaultAccount()
      selectCategoryVC.itemClass = "Account"
      selectCategoryVC.delegate = self
      
      navigationController?.pushViewController(selectCategoryVC, animated: true)
    case 3:
      let presentationController: TutorialViewController = {
        return TutorialViewController(pages: [])
        }()
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        self.presentViewController(presentationController, animated: true, completion: nil)
      }
    default:
      break
    }
  }
  
}

extension SettingsViewController: SelectAccountOrCategoryDelegate {
  func selectAccountOrCategoryViewController(selectAccountOrCategoryController: SelectAccountOrCategoryViewController, selectedItem item: AnyObject, selectedType type: String?) {
    if item is Account {
      let account = item as! Account
      print(account)
      //            let user = User.current()!
      //            user.object!.setObject(account._object!, forKey: "defaultAccount")
      //            user.save()
      
      tableView.reloadData()
    }
  }
}
