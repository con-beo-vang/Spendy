//
//  RemiderCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/19/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import SevenSwitch

@objc protocol ReminderCellDelegate {
    optional func reminderCellSwitchValueChanged(reminderCell: ReminderCell, didChangeValue value: Bool)
}

class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var timesLabel: UILabel!
    
    @IBOutlet weak var switchView: UIView!
    
    var onSwitch: SevenSwitch!
    
    var delegate: ReminderCellDelegate!

    var userCategory: UserCategory! {
        didSet {
            categoryLabel.text = userCategory.name
            timesLabel.text = getTimeSlotsString(userCategory.timeSlots)
//            timesLabel.sizeToFit()
            
            iconView.image = Helper.sharedInstance.createIcon(userCategory.icon)

            iconView.setNewTintColor(UIColor.whiteColor())
            iconView.layer.backgroundColor = Color.expenseColor.CGColor
            
            onSwitch.on = userCategory.reminderOn
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        timesLabel.preferredMaxLayoutWidth = timesLabel.frame.size.width
        
        Helper.sharedInstance.setIconLayer(iconView)
        iconView.layer.backgroundColor = Color.expenseColor.CGColor
        
        onSwitch = SevenSwitch(frame: CGRect(x: 0, y: 0, width: 51, height: 31))
        
        onSwitch.thumbTintColor = UIColor.whiteColor()
        onSwitch.activeColor =  UIColor.clearColor()
        onSwitch.inactiveColor =  UIColor.clearColor()
        onSwitch.onTintColor =  Color.strongColor
        onSwitch.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        onSwitch.shadowColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
        
        switchView.addSubview(onSwitch)
        
        onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timesLabel.preferredMaxLayoutWidth = timesLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        if delegate != nil {
            delegate?.reminderCellSwitchValueChanged?(self, didChangeValue: onSwitch.on)
        }
    }
    
    func getTimeSlotsString(timeSlots: [ReminderItem]) -> String {
        var result = ""
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        
        for item in timeSlots {
            result += formatter.stringFromDate(item.reminderTime) + ", "
        }
        
        result = result[0..<result.characters.count - 2]
        return result
    }

}
