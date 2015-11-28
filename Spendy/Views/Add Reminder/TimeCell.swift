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
  
  var reminderItem: ReminderItem! {
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
    onSwitch.borderColor = UIColor(netHex: 0xDCDCDC)
    onSwitch.shadowColor = UIColor(netHex: 0x646464)
    
    switchView.addSubview(onSwitch)
    
    onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
  }
  
  func switchValueChanged() {
    delegate?.timeCellSwitchValueChanged!(self, didChangeValue: onSwitch.on)
  }
  
}
