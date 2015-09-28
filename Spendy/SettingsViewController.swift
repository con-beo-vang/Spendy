//
//  SettingsViewController.swift
//  Spendy
//
//  Created by Harley Trung on 9/17/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import Parse

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        saveEmailButton.layer.borderColor = UIColor.darkGrayColor().CGColor
//        saveEmailButton.layer.borderWidth = 0.1
//        saveEmailButton.layer.cornerRadius = 10
//        saveEmailButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
//
//        refreshViewsForUser()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        
        avatarView.setNewTintColor(Color.strongColor)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func login() {
        PFUser.logInWithUsernameInBackground(
            emailTextField.text!, password: defaultPassword, block: { (user: PFUser?, error: NSError?) -> Void in
                if error != nil {
                    print("Error logging in: \(error)", terminator: "\n")
                } else {
                    print("Logged in successfully", terminator: "\n")
                    self.refreshViewsForUser()
                }
        })
    }

    @IBAction func onResetData(sender: AnyObject) {
        resetDataButton.enabled = false
        DataManager.setupDefaultData(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onSaveEmail(sender: AnyObject) {
        if !emailTextField.text!.isEmpty {
            if let user = PFUser.currentUser() {
                if userIsAnonymous() {
                    user.email = emailTextField.text
                    user.username = user.email
                    user.password = defaultPassword
                    // User is new
                    user.signUpInBackgroundWithBlock({ (succeeded, error: NSError?) -> Void in
                        if error != nil {
                            print("Error signing up: \(error). User: \(user)", terminator: "\n")
                            print("Try logging in:", terminator: "\n")
                            self.login() // temporary
                        } else {
                            print("Signed up successfully", terminator: "\n")
                            self.refreshViewsForUser()
                        }
                    })
                } else {
                    login()
                }
            }
        }
    }

    func disableSaveIfEmailIsEmpty() {
        if emailTextField.text!.isEmpty {
            saveEmailButton.enabled = false
        } else {
            saveEmailButton.enabled = true
        }
    }

    func userIsAnonymous() -> Bool {
        let user = PFUser.currentUser()!
        let anonymous = PFAnonymousUtils.isLinkedWithUser(user)
        print("anonymous: \(anonymous)", terminator: "\n")
        return anonymous
    }

    func refreshViewsForUser() {
        // because we allow anonymous login, this should never be nil
        let user = PFUser.currentUser()!
        print("current user: \(user)", terminator: "\n")

        emailTextField.text = user.email

        if userIsAnonymous() {
            accountStatusLabel.text = "You are not logged in."
            logoutButton.hidden = true
        } else {
            accountStatusLabel.text = "Settings are saved to account \(user.email!)"
            logoutButton.hidden = false
        }
        disableSaveIfEmailIsEmpty()
    }

    // MARK: - button actions
    @IBAction func onEmailTextChanged(sender: AnyObject) {
        disableSaveIfEmailIsEmpty()
    }

    @IBAction func onLogout(sender: UIButton) {
        PFUser.logOut()
        print("Logged out. User: \(PFUser.currentUser())", terminator: "\n")
        // refreshViewsForUser()
        
        // Transfer to Login view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        presentViewController(loginVC, animated: true, completion: nil)
    }
    
    // MARK: Implement delegate
    
    func themeCell(themeCell: ThemeCell, didChangeValue value: Bool) {
        
        //        let indexPath = tableView.indexPathForCell(themeCell)!
        print("switch theme", terminator: "\n")
        // TODO: handle time switch
        Color.isGreen = value
        print(Color.isGreen)
//        navigationController?.toolbar.backgroundColor = Color.strongColor
        
        UINavigationBar.appearance().barTintColor = Color.strongColor
        UITabBar.appearance().tintColor = Color.strongColor
        
        self.viewDidLoad()
        

    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dummyCell = UITableViewCell()

        switch indexPath.row {
            case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultAccountCell", forIndexPath: indexPath) as! DefaultAccountCell
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
            let cell = tableView.dequeueReusableCellWithIdentifier("LogOutCell", forIndexPath: indexPath) as! LogOutCell
            cell.logoutButton.setTitleColor(Color.moreDetailColor, forState: UIControlState.Normal)
            return cell
        default:
            break
        }

        return dummyCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let selectCategoryVC = storyboard.instantiateViewControllerWithIdentifier("SelectAccountOrCategoryVC") as! SelectAccountOrCategoryViewController
            
            selectCategoryVC.itemClass = "Account"
            
            navigationController?.pushViewController(selectCategoryVC, animated: true)
        }
    }

}
