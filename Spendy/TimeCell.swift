//
//  TimeCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/19/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import SevenSwitch

@objc protocol TimeCellDelegate {
    optional func timeCellSwitchValueChanged(timeCell: TimeCell, didChangeValue value: Bool)
}

class TimeCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var switchView: UIView!
    
    @IBOutlet weak var predictedAmountLabel: UILabel!

    var onSwitch: SevenSwitch!
    
    var delegate: TimeCellDelegate!
    
    var reminderItem: RReminderItem! {
        didSet {
            timeLabel.text = DateFormatter.hh_mm_a.stringFromDate(reminderItem.reminderTime!)
            onSwitch.on = reminderItem.isActive

            predictedAmountLabel.text = "~ \(reminderItem.formattedPredictedAmount())"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        onSwitch = SevenSwitch(frame: CGRect(x: 0, y: 0, width: 42, height: 25))
        
        onSwitch.thumbTintColor = UIColor.whiteColor()
        onSwitch.activeColor =  UIColor.clearColor()
        onSwitch.inactiveColor =  UIColor.clearColor()
        onSwitch.onTintColor =  Color.strongColor
        onSwitch.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        onSwitch.shadowColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
        
        switchView.addSubview(onSwitch)
        
        onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        delegate?.timeCellSwitchValueChanged!(self, didChangeValue: onSwitch.on)
    }

}
