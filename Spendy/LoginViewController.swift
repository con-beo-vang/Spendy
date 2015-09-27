//
//  LoginViewController.swift
//  Spendy
//
//  Created by Dave Vo on 9/26/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logoView: UIImageView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var retrievePassword: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
    
    var isRegisterMode = false
    
    var name = ""
    var email = ""
    var password = ""
    
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
        
//        loginButton.layer.backgroundColor = UIColor(netHex: 0xfcc96f).CGColor
        
        tableViewHeightConstraint.constant = isRegisterMode ? 132 : 88

    }
    
    override func viewWillAppear(animated: Bool) {
        setColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setColor() {
        
        view.backgroundColor = Color.loginBackgroundColor
        logoView.setNewTintColor(Color.strongColor)
        appNameLabel.textColor = Color.appNameColor
        loginButton.layer.backgroundColor = Color.strongColor.CGColor
        loginButton.tintColor = UIColor.whiteColor()
        registerButton.setTitleColor(Color.registerColor, forState: UIControlState.Normal)
        retrievePassword.setTitleColor(Color.forgotPasswordColor, forState: UIControlState.Normal)
    }
    
    // MARK: Button
    
    @IBAction func onLogin(sender: UIButton) {
        print("on Login")
        
        email = (getTextField(1)?.text)!
        password = (getTextField(2)?.text)!
        
        if isRegisterMode {
            name = (getTextField(0)?.text)!
            // TODO: Handle Register
        } else {
            // TODO: Handle Login
        }
        
        performSegueWithIdentifier("GoToHome", sender: self)
    }
    
    @IBAction func onRegister(sender: UIButton) {
        if isRegisterMode {
            isRegisterMode = false
            loginButton.setTitle("Login", forState: UIControlState.Normal)
            registerButton.setTitle("Register", forState: UIControlState.Normal)
            name = (getTextField(0)?.text)!
            email = (getTextField(1)?.text)!
            password = (getTextField(2)?.text)!
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
            tableViewHeightConstraint.constant = 88
        } else {
            isRegisterMode = true
            loginButton.setTitle("Register", forState: UIControlState.Normal)
            registerButton.setTitle("Back to Login", forState: UIControlState.Normal)
            email = (getTextField(1)?.text)!
            password = (getTextField(2)?.text)!
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
            tableViewHeightConstraint.constant = 132
        }
        

    }
    
    @IBAction func onRetrievePassword(sender: UIButton) {
        print("on Retrieve password")
    }
    

    // MARK: Keyboard
    
    func keyboardWasShown(notification: NSNotification) {
        
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
    
    func keyboardWasHiden(notification: NSNotification) {
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.logoView.transform = CGAffineTransformMakeScale(1.25, 1.25)
            self.appNameLabel.transform = CGAffineTransformMakeScale(1.25, 1.25)
            self.logoTopConstraint.constant = 100
            self.logoBottomConstraint.constant = 16
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
            cell.textField.text = name
            break
            
        case 1:
            cell.textField.placeholder = "Email Address"
            cell.textField.text = email
            break
            
        case 2:
            cell.textField.placeholder = "Password"
            cell.textField.text = password
            cell.textField.secureTextEntry = true
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

