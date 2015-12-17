//
//  DateCell.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

@objc protocol DateCellDelegate {
  func dateCell(dateCell: DateCell, selectedDate: NSDate)
}

class DateCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  weak var delegate: DateCellDelegate!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    datePicker.backgroundColor = UIColor.whiteColor()
  }
  
  @IBAction func onDatePicker(sender: AnyObject) {
    let selectedDate = datePicker.date
    let strDate = DateFormatter.E_MMM_dd_yyyy.stringFromDate(selectedDate)
    dateLabel.text = strDate
    delegate?.dateCell(self, selectedDate: selectedDate)
  }
}
