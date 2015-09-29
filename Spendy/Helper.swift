//
//  Helper.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

var logoColor = UIColor.redColor()


class Helper: NSObject {
    
    static let sharedInstance = Helper()
    
    func customizeBarButton(viewController: UIViewController, button: UIButton, imageName: String, isLeft: Bool) {
        
        let avatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        avatar.image = UIImage(named: imageName)
        
        button.setImage(avatar.image, forState: .Normal)
        button.frame = CGRectMake(0, 0, 22, 22)
        
        let item: UIBarButtonItem = UIBarButtonItem()
        item.customView = button
        //        item.customView?.layer.cornerRadius = 11
        //        item.customView?.layer.masksToBounds = true
        if isLeft {
            viewController.navigationItem.leftBarButtonItem = item
        } else {
            viewController.navigationItem.rightBarButtonItem = item
        }
    }
    
    func setSeparatorFullWidth(cell: UITableViewCell) {
        // Set full width for the separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    func getCellAtGesture(gestureRecognizer: UIGestureRecognizer, tableView: UITableView) -> UITableViewCell? {
        let location = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(location)
        if let indexPath = indexPath {
            return tableView.cellForRowAtIndexPath(indexPath)!
        } else {
            return nil
        }
    }
    
    
    
    func showActionSheet(viewController: UIViewController, imagePicker: UIImagePickerController) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take a Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take a Photo", terminator: "\n")
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
            imagePicker.modalPresentationStyle = .FullScreen
            viewController.presentViewController(imagePicker, animated: true, completion: nil)
        })
        
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Photo from Library", terminator: "\n")
            
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .PhotoLibrary
            viewController.presentViewController(imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled", terminator: "\n")
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(cancelAction)
        
        viewController.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func setPopupShadowAndColor(popupView: UIView, label: UILabel) {
        
        // Set shadow
        popupView.layer.shadowPath = UIBezierPath(roundedRect: popupView.layer.bounds, cornerRadius: 5).CGPath
        popupView.layer.shadowColor = Color.strongColor.CGColor
        popupView.layer.shadowOffset = CGSizeMake(5, 5)
        popupView.layer.shadowRadius = 5
        popupView.layer.shadowOpacity = 0.5
        
        // Set header color
        label.backgroundColor = Color.popupHeaderColor
        label.textColor = UIColor.whiteColor()
    }
    
    // MARK: Category
    
    func createIcon(imageName: String) -> UIImage {
        
        let markerView = UIView(frame:CGRectMake(0, 0, 50, 50))
        
        //Add icon
        let icon = UIImageView(frame: CGRectMake(7, 7, 36, 36))
        icon.image = UIImage(named: imageName)
        markerView.addSubview(icon)
        
        return imageFromView(markerView)
    }
    
    func imageFromView(aView:UIView) -> UIImage {
        
        if(UIScreen.mainScreen().respondsToSelector("scale")) {
            UIGraphicsBeginImageContextWithOptions(aView.frame.size, false, UIScreen.mainScreen().scale)
        }
        else {
            UIGraphicsBeginImageContext(aView.frame.size)
        }
        aView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setIconLayer(iconView: UIImageView) {
        iconView.layer.cornerRadius = iconView.frame.height / 2
        iconView.layer.masksToBounds = true
        // TODO: remove this line after category has type
        iconView.layer.backgroundColor = Color.strongColor.CGColor
    }
    
}

extension String {
    
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIImageView {
    
    func setNewTintColor(color: UIColor) {
        self.image = self.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tintColor = color
    }
}

extension UITableView {
    
    func reloadDataWithBlock(completion: ()->()) {
        UIView.animateWithDuration(0, animations: { self.reloadData() })
            { _ in completion() }
    }
}

enum ViewMode: Int {
    case Weekly = 0,
    Monthly,
    Yearly,
    Custom
}
