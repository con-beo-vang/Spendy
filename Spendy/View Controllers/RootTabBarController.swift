//
//  RootTabBarController.swift
//  Spendy
//
//  Created by Harley Trung on 9/17/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit
import SwiftSpinner

class RootTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    SwiftSpinner.hide()
    
    // print("RootTabBarController:viewDidLoad")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      // Call with true to reset data
      DataManager.setupDefaultData(false)
    }
    
    // Replace the Settings placeholder controller
    // Load Settings storyboard's initial controller
    let storyboard = UIStoryboard(name: "Settings", bundle: nil)
    let settingsController = storyboard.instantiateInitialViewController() as! UINavigationController
    
    if var tabControllers = self.viewControllers {
      assert(tabControllers[2] is SettingsViewController, "Expecting the 3rd tab is SettingsController")
      tabControllers[2] = settingsController
      self.setViewControllers(tabControllers, animated: true)
    } else {
      print("Error hooking up Settings tab", terminator: "")
    }
  }
  
  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    if item.title == "Add" {
      tabBar.hidden = true
    }
  }
  
}
