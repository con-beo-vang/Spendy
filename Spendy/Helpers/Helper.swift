//
//  Helper.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import RealmSwift

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
    if isLeft {
      viewController.navigationItem.leftBarButtonItem = item
    } else {
      viewController.navigationItem.rightBarButtonItem = item
    }
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

// MARK: - Setup Realm

extension Helper {
  
  static func setDefaultRealmForUser(email: String) {
    createFolderWithEmail(email)
    
    var config = Realm.Configuration()
    
    // Use the default directory, but replace the filename with the username
    config.path = NSURL.fileURLWithPath(config.path!)
      .URLByDeletingLastPathComponent?
      .URLByAppendingPathComponent("\(email)/\(email).realm")
      .path
    
    // Set this as the configuration used for the default Realm
    Realm.Configuration.defaultConfiguration = config
    
    print("\n=====================")
    print(Realm.Configuration.defaultConfiguration)
    print("=====================\n")
  }
  
  // Get the documents Directory
  static func createFolderWithEmail(email: String) -> String {
    let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as NSString
    let newFolderPath = documentsFolderPath.stringByAppendingPathComponent(email)
    
    // Create new folder
    if !NSFileManager.defaultManager().fileExistsAtPath(newFolderPath) {
      do {
        try NSFileManager.defaultManager().createDirectoryAtPath(newFolderPath, withIntermediateDirectories: false, attributes: nil)
      } catch let createDirectoryError as NSError {
        print("Error with creating directory at path: \(createDirectoryError.localizedDescription)")
      }
    }
    
    return newFolderPath
  }
  
}

// MARK: - Save poster to documents directory

extension Helper {
  
  static func savePhotoLocal(image: UIImage, email: String, filename: String) -> Bool {
    let userFolderPath = createFolderWithEmail(email) as NSString
    let filePath = userFolderPath.stringByAppendingPathComponent(filename)
    if let jpgImageData = UIImageJPEGRepresentation(image, 1.0) {
      return jpgImageData.writeToFile(filePath, atomically: true)
    }
    return false
  }
  
  static func deleteOldPhoto(photoPath: String) {
    let fileManager = NSFileManager.defaultManager()
    do {
      try fileManager.removeItemAtPath(photoPath)
    } catch {
      print("Cannot delete old photo")
    }
  }
  
}

enum ViewMode: Int {
  case Weekly = 0,
  Monthly,
  Yearly,
  Custom
}
