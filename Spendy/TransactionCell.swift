//
//  TransactionCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/19/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

//    var currentAccount: Account?
    var currentRAccount: RAccount?

    var transaction: RTransaction! {
        didSet {
            if let noteText = transaction.note {
                if noteText.isEmpty {
                    noteLabel.text = transaction.categoryName
                } else {
                    noteLabel.text = noteText
                }
            } else {
                noteLabel.text = transaction.categoryName
            }

            amountLabel.text = transaction.formattedAmount()
            amountLabel.textColor = KindColor.forKind(transaction.kind!)
            dateLabel.text = transaction.dateOnly()

            // TODO: which balance to display
            if let account   = currentRAccount,
                   toAccount = transaction.toAccount
                where account == toAccount {
                balanceLabel.text = transaction.formattedToBalanceSnapshot()
            } else {
                balanceLabel.text = transaction.formattedBalanceSnapshot()
            }

            if let icon = transaction.categoryIcon {
                iconView.image = Helper.sharedInstance.createIcon(icon)
                iconView.setNewTintColor(UIColor.whiteColor())
                switch transaction.kind! {
                case CategoryType.Expense.rawValue:
                    iconView.layer.backgroundColor = Color.expenseColor.CGColor
                case CategoryType.Income.rawValue:
                    iconView.layer.backgroundColor = Color.incomeColor.CGColor
                case CategoryType.Transfer.rawValue:
                    iconView.layer.backgroundColor = Color.transferIconColor.CGColor
                default:
                    break
                }
            }

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Helper.sharedInstance.setIconLayer(iconView)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
