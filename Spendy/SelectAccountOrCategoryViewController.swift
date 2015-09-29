//
//  SelectAccountOrCategoryViewController.swift
//  Spendy
//
//  Created by Harley Trung on 9/17/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import Parse

protocol SelectAccountOrCategoryDelegate {
    func selectAccountOrCategoryViewController(selectAccountOrCategoryController: SelectAccountOrCategoryViewController, selectedItem item: AnyObject)
}

class SelectAccountOrCategoryViewController: UIViewController {
    // Account or Category
    var itemClass: String!
    var delegate: SelectAccountOrCategoryDelegate?

    @IBOutlet weak var tableView: UITableView!
    var items: [HTObject]?

    var backButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBarButton()

        tableView.dataSource = self
        tableView.delegate = self

        loadItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadItems() {
        if itemClass == "Category" {
            navigationItem.title = "Select Category"
            items = Category.all as [Category]
            tableView.reloadData()
        } else if itemClass == "Account" {
            navigationItem.title = "Select Account"
            items = Account.all() as [Account]?
            tableView.reloadData()
        }
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
}

extension SelectAccountOrCategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return items?.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }

    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell") as! CategoryCell

        if let item = items?[indexPath.row] {
            cell.nameLabel.text = item["name"] as! String?
            if let icon = item["icon"] as? String {
                
                cell.iconImageView.image = Helper.sharedInstance.createIcon(icon)
                cell.iconImageView.setNewTintColor(UIColor.whiteColor())
                // TODO: set color for icon depending on kind of transaction
//                if [expense] {
//                    cell.iconImageView.layer.backgroundColor = Color.expenseIconColor.CGColor
//                } else {
//                    cell.iconImageView.layer.backgroundColor = Color.expenseIconColor.CGColor
//                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        var cell = tableView.cellForRowAtIndexPath(indexPath) as! CategoryCell
        navigationController?.popViewControllerAnimated(true)
        delegate?.selectAccountOrCategoryViewController(self, selectedItem: items![indexPath.row])
    }

}