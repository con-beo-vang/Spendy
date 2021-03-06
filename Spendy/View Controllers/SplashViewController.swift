//
//  SplashViewController.swift
//  Spendy
//
//  Created by Dave Vo on 10/3/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
import CBZSplashView
import Parse

class SplashViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Choose a different image from a list of Cheetah-0, Cheetah-1, ... Cheetah-count etc
    let count = 2
    let index = Int(arc4random_uniform(UInt32(count)))
    let icon = UIImage(named: "Cheetah-\(index)")
    
    configSplashView(icon!)
  }
  
  func configSplashView(icon: UIImage) {
    let splashView = CBZSplashView(icon: icon, backgroundColor: Color.strongColor)
    
    view.addSubview(splashView)
    
    splashView.animationDuration = 1.5
    
    splashView.startAnimationWithCompletionHandler { () -> Void in
      
      let user = PFUser.currentUser()
      
      // TODO: check login
      let isLoggedIn = user != nil
      
      if isLoggedIn {
        // Go to Home screen
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RootTabBarController") as! RootTabBarController
        self.presentViewController(vc, animated: true, completion: nil)
      } else {
        // Go to Login screen
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        self.presentViewController(vc, animated: true, completion: nil)
      }
    }
  }
  
}
