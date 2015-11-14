//
//  DateCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class DateCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    datePicker.backgroundColor = UIColor.whiteColor()
  }
  
  @IBAction func onDatePicker(sender: AnyObject) {
    let strDate = DateFormatter.E_MMM_dd_yyyy.stringFromDate(datePicker.date)
    dateLabel.text = strDate
  }
}
