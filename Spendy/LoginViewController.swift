//
//  LoginViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/26/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    
    var isRegisterMode = false
    
    let customPresentAnimationController = CustomPresentAnimationController()
    let customDismissAnimationController = CustomDismissAnimationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHiden:"), name:UIKeyboardWillHideNotification, object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        tableView.separatorColor = UIColor(netHex: 0xE9E9E9)
        tableView.layer.borderColor = UIColor(netHex: 0xE9E9E9).CGColor
        tableView.layer.borderWidth = 1
        
        loginButton.layer.backgroundColor = UIColor(netHex: 0x28AD60).CGColor
        loginButton.tintColor = UIColor.whiteColor()
        
        tableViewHeightConstraint.constant = isRegisterMode ? 132 : 88

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button
    
    @IBAction func onLogin(sender: UIButton) {
        print("on Login")
        // TODO: Handle Login

        performSegueWithIdentifier("GoToHome", sender: self)
    }
    
    @IBAction func onRegister(sender: UIButton) {
        isRegisterMode = true
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
        tableViewHeightConstraint.constant = 132

    }
    
    @IBAction func onRetrievePassword(sender: UIButton) {
        print("on Retrieve password")
    }
    

    // MARK: Keyboard
    
    func keyboardWasShown(notification: NSNotification) {
        
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.logoTopConstraint.constant = 15
            self.bottomConstraint.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardWasHiden(notification: NSNotification) {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.logoTopConstraint.constant = 145
            self.bottomConstraint.constant = 0
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for i in 0...2 {
            if let cell = getTextField(i) {
                cell.resignFirstResponder()
            }
        }
    }
}

// MARK: Table view

extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return isRegisterMode ? 44 : 0
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LoginCell", forIndexPath: indexPath) as! LoginCell
        
        switch indexPath.row {
        case 0:
            cell.textField.placeholder = "Name"
            break
            
        case 1:
            cell.textField.placeholder = "Email Address"
            break
            
        case 2:
            cell.textField.placeholder = "Password"
            break
        default:
            break
        }
        
        Helper.sharedInstance.setSeparatorFullWidth(cell)
        return cell
    }
    
    func getTextField(indexPathRow: Int) -> UITextField? {
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPathRow, inSection: 0)) as! LoginCell! {
            return cell.textField
        }
        return nil
    }
}

// MARK: Custom transition

extension LoginViewController: UIViewControllerTransitioningDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToHome" {
            let toViewController = segue.destinationViewController as! UITabBarController
            toViewController.transitioningDelegate = self
            customPresentAnimationController.animationType = CustomSegueAnimation.CornerRotate
            customDismissAnimationController.animationType = CustomSegueAnimation.CornerRotate
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customPresentAnimationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customDismissAnimationController
    }
    
}

