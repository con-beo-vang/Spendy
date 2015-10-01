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
    func selectAccountOrCategoryViewController(selectAccountOrCategoryController: SelectAccountOrCategoryViewController, selectedItem item: AnyObject, selectedType type: String?)
}

class SelectAccountOrCategoryViewController: UIViewController {
    // Account or Category
    var itemClass: String!

    // Income, Expense or Transfer
    var itemTypeFilter: String?

    // pass back selected item
    var delegate: SelectAccountOrCategoryDelegate?

    @IBOutlet weak var tableView: UITableView!

    var items: [HTObject]?

    var backButton: UIButton?
    
    var selectedItem: HTObject?

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
        print("loadItems: \(itemTypeFilter)")
        if itemClass == "Category" {
            navigationItem.title = "Select Category"

            switch itemTypeFilter {
            case .Some("Income"):
                items = Category.allIncomeType as [Category]

            case .Some("Expense"):
                items = Category.allExpenseType as [Category]

            case .Some("Transfer"):
                items = Category.allTransferType as [Category]

            default:
                print("WARNING: loadItems called on unrecognized type \(itemTypeFilter)")
                items = Category.all as [Category]
            }

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
            
            if item.objectId == selectedItem?.objectId {
                cell.selectedIcon.hidden = false
            } else {
                cell.selectedIcon.hidden = true
            }
            
            if let icon = item["icon"] as? String {
                
                cell.iconImageView.image = Helper.sharedInstance.createIcon(icon)
                cell.iconImageView.setNewTintColor(UIColor.whiteColor())

                switch itemTypeFilter {
                case .Some("Expense"):
                    cell.iconImageView.layer.backgroundColor = Color.expenseColor.CGColor
                    cell.selectedIcon.setNewTintColor(Color.expenseColor)
                case .Some("Income"):
                    cell.iconImageView.layer.backgroundColor = Color.incomeColor.CGColor
                    cell.selectedIcon.setNewTintColor(Color.incomeColor)
                case .Some("Transfer"):
                    cell.iconImageView.layer.backgroundColor = Color.balanceColor.CGColor
                    cell.selectedIcon.setNewTintColor(Color.balanceColor)
                default:
                    // nothing
                    cell
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // var cell = tableView.cellForRowAtIndexPath(indexPath) as! CategoryCell
        navigationController?.popViewControllerAnimated(true)
        delegate?.selectAccountOrCategoryViewController(self, selectedItem: items![indexPath.row], selectedType: itemTypeFilter)
    }
}