//
//  LoginViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/26/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
import Parse
import SwiftSpinner

enum LoginMode: Int {
  case Login = 0
  case Register
  case ForgotPassword
}

class LoginViewController: UIViewController {
  
  @IBOutlet weak var logoView: UIImageView!
  
  @IBOutlet weak var appNameLabel: UILabel!
  
  @IBOutlet weak var primaryButton: UIButton!
  
  @IBOutlet weak var secondaryButton: UIButton!
  
  @IBOutlet weak var retrievePassword: UIButton!
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
  
  // Default mode is Login mode
  var loginMode = LoginMode.Login
  
  let customPresentAnimationController = CustomPresentAnimationController()
  let customDismissAnimationController = CustomDismissAnimationController()
  
  var name: String? { return getTextField(0)?.text }
  var email: String? { return getTextField(1)?.text?.lowercaseString }
  var password: String? { return getTextField(2)?.text }
  
  // MARK: - Main functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configTableView()
    setNotification()
  }
  
  override func viewWillAppear(animated: Bool) {
    setColor()
  }
  
  func configTableView() {
    tableView.separatorColor = UIColor(netHex: 0xE9E9E9)
    tableView.layer.borderColor = UIColor(netHex: 0xE9E9E9).CGColor
    tableView.layer.borderWidth = 1
    
    tableView.tableFooterView = UIView()
    tableViewHeightConstraint.constant = loginMode == .Register ? 132 : 88
  }
  
  func setNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
  }
  
  func setColor() {
    view.backgroundColor = Color.loginBackgroundColor
    logoView.setNewTintColor(Color.strongColor)
    appNameLabel.textColor = Color.appNameColor
    primaryButton.layer.backgroundColor = Color.strongColor.CGColor
    primaryButton.tintColor = UIColor.whiteColor()
    secondaryButton.setTitleColor(Color.registerColor, forState: UIControlState.Normal)
    retrievePassword.setTitleColor(Color.forgotPasswordColor, forState: UIControlState.Normal)
  }
  
  // MARK: Button
  
  @IBAction func onPrimaryButton(sender: UIButton) {
    // Dismiss keyoboard
    view.endEditing(true)
    
    switch loginMode {
      // TODO: add checkbox or popup to ask the user to agree on terms?
    case .Register: processRegistration()
    case .Login: processLoggingIn()
    case .ForgotPassword: processPasswordRetrieval()
    }
  }
  
  // Display error message to user
  func handleUserInfoError(error: NSError) {
    if let message = error.userInfo["error"] {
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        SwiftSpinner.show("\(message)", animated: false).addTapHandler(
          { SwiftSpinner.hide() }, subtitle: "Tap to try again"
        )
      }
    } else { SwiftSpinner.hide() }
  }
  
  func processLoggingIn() {
    SwiftSpinner.show("Logging in...")
    PFUser.logInWithUsernameInBackground(email!, password: password!) {
      (user: PFUser?, error: NSError?) -> Void in
      if let error = error {
        self.handleUserInfoError(error)
        return
      }
      
      if let user = user {
        print("Logging in as \(user)")
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
          self.performSegueWithIdentifier("GoToHome", sender: self)
        }
      }
    }
  }
  
  func processRegistration() -> Bool {
    SwiftSpinner.show("Registering...")
    
    // update user
    guard PFUser.currentUser() == nil else { return false }
    
    let user = PFUser()
    user["name"] = name
    user.username = email
    user.email = email
    user.password = password
    
    // TODO: validate user info here and return false if invalid
    
    // TODO: refactor into User
    user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
      if let error = error {
        self.handleUserInfoError(error)
        return
      }
      
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        self.performSegueWithIdentifier("GoToHome", sender: self)
      }
    }
    
    return true
  }
  
  func processPasswordRetrieval() {
    SwiftSpinner.show("Sending you instructions...")
    guard let email = email else {
      print("Email is empty")
      return
    }
    
    PFUser.requestPasswordResetForEmailInBackground(email) { (succeeded, error) -> Void in
      if let error = error {
        self.handleUserInfoError(error)
      } else {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
          SwiftSpinner.show("Your request is successful. Please check your email", animated: false).addTapHandler(
            { SwiftSpinner.hide() }, subtitle: "Tap to return"
          )
        }
      }
    }
  }
  
  // Extra: we're displaying error messages with SwiftSpinner instead
  func alertWithMessage(title: String?, message: String? = nil) {
    // Build the terms and conditions alert
    let alertController = UIAlertController(title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    alertController.addAction(UIAlertAction(title: "OK",
      style: UIAlertActionStyle.Default,
      handler: nil)
    )
    
    // Display alert
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  // Optional: if we want user to agree to some terms
  func confirmToRegister(sender: AnyObject) {
    // Build the terms and conditions alert
    let alertController = UIAlertController(title: "Agree to terms and conditions",
      message: "Click I AGREE to confirm that you agree to the End User Licence Agreement.",
      preferredStyle: UIAlertControllerStyle.Alert
    )
    alertController.addAction(UIAlertAction(title: "I AGREE",
      style: UIAlertActionStyle.Default,
      handler: { alertController in self.processRegistration()})
    )
    alertController.addAction(UIAlertAction(title: "I do NOT agree",
      style: UIAlertActionStyle.Default,
      handler: nil)
    )
    
    // Display alert
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func showFieldsToLogin() {
    loginMode = .Login
    primaryButton.setTitle("Login", forState: UIControlState.Normal)
    secondaryButton.setTitle("Register", forState: UIControlState.Normal)
    
    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
    tableViewHeightConstraint.constant = 88
  }
  
  func showFieldsToRegister() {
    loginMode = .Register
    primaryButton.setTitle("Register", forState: UIControlState.Normal)
    secondaryButton.setTitle("Back to Login", forState: UIControlState.Normal)
    
    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
    tableViewHeightConstraint.constant = 132
  }
  
  func showFieldsToResetPassword() {
    loginMode = .ForgotPassword
    primaryButton.setTitle("Email me to reset my password", forState: UIControlState.Normal)
    secondaryButton.setTitle("Back to Login", forState: UIControlState.Normal)
    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
    tableViewHeightConstraint.constant = 44
  }
  
  // Clicking on the secondaryButton will reset the login form
  @IBAction func onSecondaryButton(sender: UIButton) {
    switch loginMode {
    case .Register: showFieldsToLogin()
    case .Login: showFieldsToRegister()
    case .ForgotPassword: showFieldsToLogin()
    }
  }
  
  // Click on link "Forgot your password" at the bottom will update the login form
  @IBAction func onRetrievePassword(sender: UIButton) {
    print("on Retrieve password")
    showFieldsToResetPassword()
  }
  
  // MARK: Keyboard
  
  func keyboardWillShow(notification: NSNotification) {
    var info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    
    UIView.animateWithDuration(01, animations: { () -> Void in
      self.logoView.transform = CGAffineTransformMakeScale(0.8, 0.8)
      self.appNameLabel.transform = CGAffineTransformMakeScale(0.8, 0.8)
      self.logoTopConstraint.constant = 0
      self.logoBottomConstraint.constant = -4
      self.bottomConstraint.constant = keyboardFrame.size.height
    })
  }
  
  func keyboardWillHide(notification: NSNotification) {
    UIView.animateWithDuration(1, animations: { () -> Void in
      self.logoView.transform = CGAffineTransformMakeScale(1.25, 1.25)
      self.appNameLabel.transform = CGAffineTransformMakeScale(1.25, 1.25)
      self.logoTopConstraint.constant = 100
      self.logoBottomConstraint.constant = 16
      self.bottomConstraint.constant = 0
    })
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    view.endEditing(true)
  }
  
}

// MARK: - Table view

extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == 0 {
      return loginMode == .Register ? 44 : 0
    } else {
      return 44
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LoginCell", forIndexPath: indexPath) as! LoginCell
    
    switch indexPath.row {
    case 0:
      cell.textField.placeholder = "Name"
      cell.textField.text = name
      cell.textField.secureTextEntry = false
      
    case 1:
      cell.textField.placeholder = "Email Address"
      cell.textField.text = email
      cell.textField.secureTextEntry = false
      cell.textField.keyboardType = .EmailAddress
      
    case 2:
      cell.textField.placeholder = "Password"
      cell.textField.text = password
      cell.textField.secureTextEntry = true
      
    default:
      break
    }
    
    cell.setSeparatorFullWidth()
    return cell
  }
  
  func getTextField(indexPathRow: Int) -> UITextField? {
    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPathRow, inSection: 0)) as! LoginCell! {
      return cell.textField
    }
    return nil
  }
  
}

// MARK: - Custom transition

extension LoginViewController: UIViewControllerTransitioningDelegate {
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "GoToHome" {
      let toViewController = segue.destinationViewController as! UITabBarController
      toViewController.transitioningDelegate = self
      customPresentAnimationController.animationType = CustomSegueAnimation.GrowScale
      customDismissAnimationController.animationType = CustomSegueAnimation.GrowScale
    }
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return customPresentAnimationController
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return customDismissAnimationController
  }
  
}
