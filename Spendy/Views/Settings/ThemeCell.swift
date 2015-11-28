//
//  ThemeCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/27/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
import SevenSwitch

@objc protocol ThemeCellDelegate {
  optional func themeCell(timeCell: ThemeCell, didChangeValue value: Bool)
}

class ThemeCell: UITableViewCell {
  
  @IBOutlet weak var switchView: UIView!
  
  var onSwitch: SevenSwitch!
  
  var delegate: ThemeCellDelegate!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    onSwitch = SevenSwitch(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
    
    onSwitch.thumbTintColor = UIColor.whiteColor()
    onSwitch.activeColor =  UIColor.clearColor()
    onSwitch.inactiveColor =  UIColor.clearColor()
    onSwitch.onTintColor =  Color.strongColor
    onSwitch.borderColor = UIColor(netHex: 0xDCDCDC)
    onSwitch.shadowColor = UIColor(netHex: 0x646464)
    
    onSwitch.offLabel.text = "Green"
    onSwitch.onLabel.text = "Gold"
    onSwitch.onLabel.textColor = UIColor.whiteColor()
    
    switchView.addSubview(onSwitch)
    
    onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
  }
  
  func switchValueChanged() {
    if delegate != nil {
      delegate?.themeCell?(self, didChangeValue: onSwitch.on)
    }
  }
  
}
